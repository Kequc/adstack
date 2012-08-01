module Adstack
  class Api
    include ActiveModel::Validations

    MAX_ATTEMPTS = 5

    attr_accessor :customer_id

    class << self

      attr_reader :service_sym, :item_location, :doesnt_need_customer_id

      # Store service name
      def service_api(symbol, *params)
        @service_sym = symbol
        params.each do |param|

          case param
          when Hash
            param.each_pair do |key, value|

              case key
              when :r
                # Class name different from service name
                @item_sym = value
              when :l
                # Unusual nesting location in response
                @item_location = value
              end

            end

          end
        end
      end

      # Name of the current item class instance
      def item_sym
        @item_sym || self.service_sym
      end

      def item_class
        Toolkit.classify(self.item_sym)
      end

      def need_customer_id
        Adstack::MCC and !@doesnt_need_customer_id
      end

      # Unnecessary customer_id for this service
      def customer_id_free
        @doesnt_need_customer_id = true
      end

      def service_name_sym
        Toolkit.servify(self.service_sym)
      end

      def item(params={})
        self.item_class.new(params)
      end

    end

    # Find or refresh adwords instance
    def adwords
      if @adwords and !Config.changed?
        return @adwords
      end
      @adwords = AdwordsApi::Api.new(Config.read)
      if Adstack::MCC and self.customer_id.present?
        self.adwords.config.set('authentication.client_customer_id', self.customer_id)
      end
      @adwords
    end

    # Executes get operation
    def get(operation=nil, predicates=nil)
      if predicates
        operation.merge!(predicates: predicates)
      end
      self.execute(:get, operation)
    end

    # Executes mutate operation
    def mutate(operation)
      self.execute(:mutate, Array.wrap(operation))
    end

    def mutate_explicit(operator, operand)
      self.mutate(Toolkit.operation(operator, operand))
    end

    # Instantiates adwords service
    def external_api
      self.adwords.service(self.class.service_name_sym, Adstack::API_VERSION)
    end

    # Make the operation happen
    def execute(method=:get, operation=nil)
      result = nil
      @attempts = 0

      if self.class.need_customer_id and !self.customer_id.present?
        raise "Adwords MCC #{self.class.service_name_sym} request attempted without customer_id"
      end

      if self.adwords.config.read('authentication.auth_token').blank?
        # Adwords auth token not initialized
        self.request_auth_token
      end

      begin
        @perform_retry = false
        @attempts += 1
        if operation
          result = self.external_api.send(method, operation)
        else
          result = self.external_api.send(method)
        end
    
      rescue AdsCommon::Errors::HttpError => e
        self.add_error(e.message)
        retry if @perform_retry

      # This is needed because AdWords API sometimes doesn't wrap errors properly
      rescue AdsCommon::Errors::ApiException => e
        self.add_error(e.message)
        retry if @perform_retry

      # Traps exceptions raised by AdWords API
      rescue AdwordsApi::Errors::ApiException => e
        case self.class.service_name_sym
        when :AdGroupAdService, :AdGroupCriterionService
          # Trap and format errors returned from AdGroupAdService or AdGroupCriterionService specifically
          e.errors.each do |error|
            if (error[:api_error_type] == 'PolicyViolationError') and error[:is_exemptable]
              # Ad policy violation
              self.add_error("#{error[:api_error_type]}: #{error[:key]}")
            else 
              # Include field_path in errors
              self.add_error("#{error[:error_string]} @ #{error[:field_path]}")
            end
          end
        else
          # Trap errors returned from Adwords
          e.errors.each do |error|
            self.add_error(error[:error_string])
          end
        end
        retry if @perform_retry
      end

      result
    end

    # Retrieve and manage authentication certificates
    def request_auth_token
      # Retrieve auth token
      auth_token = self.auth_token_storage
      unless auth_token
        puts 'Requesting new adwords token...'
        # Must unset adwords token
        Config.unset(:auth_token)
        auth_token = self.adwords.authorize
        # Deliver auth token
        self.auth_token_storage = auth_token
      end
      Config.set(auth_token: auth_token)
      puts "Using auth_token: #{auth_token}"
    end

    # Override these methods if you're storing the auth tokens somewhere
    def auth_token_storage
    end

    # Override these methods if you're storing the auth tokens somewhere
    def auth_token_storage=(auth_token)
    end

    # Perform actions for errors
    def add_error(error_string)
      where = :base
      self.errors.add(where, error_string)

      puts error_string
      case error_string
      when /RateExceededError/, /InternalApiError/
        sleep(5)
        # Try again
        @perform_retry = true
      when /GOOGLE_ACCOUNT_COOKIE_INVALID/, /USER_PERMISSION_DENIED/
        self.request_auth_token
        # Try again
        @perform_retry = true
      when /CUSTOMER_NOT_FOUND/
        # Account missing
      end

      @perform_retry = false if @attempts >= MAX_ATTEMPTS
    end

  end
end
