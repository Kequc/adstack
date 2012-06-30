module Adstack
  class Api

    attr_reader :customer_id, :service_name

    class << self

      # Store service name
      def service_name(symbol)
        @service_name = symbol
      end

    end

    # Store customer_id for MCC accounts
    def customer_id=(customer_id)
      @customer_id = customer_id
    end

    # Change customer_id for MCC accounts
    def set_adwords_customer_id(customer_id)
      return false unless MCC or customer_id.present?
      self.adwords.config.set('authentication.client_customer_id', @customer_id)
    end

    # Find or refresh adwords instance
    def adwords
      if @adwords and !Config.changed?
        return @adwords
      end
      @adwords = AdwordsApi::Api.new(Config.read)
      self.set_adwords_customer_id(self.customer_id) unless MCC
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
      self.adwords.service(Toolkit.servify(self.service_name), API_VERSION)
    end

    def customer_id_required?
      !!(MCC and [
        :serviced_account,
        :create_account,
        :budget_order,
        :location_criterion
      ].include?(self.service_name))
    end

    # Make the operation happen
    def execute(method=:get, operation=nil)
      result = nil
      @attempts = 0

      if self.customer_id_required? and !self.customer_id.present?
        raise "Adwords MCC #{self.service_name} request attempted without customer_id"
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
        e.message.split(",").each do |error|
          self.add_error(error.strip)
        end
        retry if @perform_retry

      # Traps exceptions raised by AdWords API
      rescue AdwordsApi::Errors::ApiException => e
        case self.service_name
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
      nil
    end

    # Override these methods if you're storing the auth tokens somewhere
    def auth_token_storage=(auth_token)
      nil
    end

  end
end
