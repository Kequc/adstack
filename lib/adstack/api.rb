module Adstack
  class Api

    attr_reader :customer_id

    def initialize(params={})
    end

    def customer_id=(customer_id)
      return false unless MCC or customer_id.present?
      @customer_id = customer_id.to_i
      self.set_adwords_customer_id(@customer_id)
      @customer_id
    end

    class << self

      def set_adwords_customer_id(customer_id)
        return false unless MCC or customer_id.present?
        self.adwords.config.set('authentication.client_customer_id', @customer_id)
      end

      def adwords
        if @adwords and !Adstack::Config.changed?
          return @adwords
        end
        @adwords = AdwordsApi::Api.new(Adstack::Config.read)
        self.set_adwords_customer_id(@customer_id)
        @adwords
      end

      def get(service_name, operation=nil, predicates=nil)
        if predicates
          operation.merge!(predicates: predicates)
        end
        self.execute(service_name, :get, operation)
      end

      def mutate(service_name, operation)
        self.execute(service_name, :mutate, Array.wrap(operation))
      end

      def mutate_explicit(service_name, operator, operand)
        self.mutate(service_name, Toolkit.operation(operator, operand))
      end

      def service_init
        self.adwords.service(Toolkit.servify(service_name), API_VERSION)
      end

      def execute(service_name, method=:get, operation=nil, service_override=nil)
        result = nil
        @attempts = 0

        if MCC
          no_customer_id = [
            :serviced_account,
            :create_account,
            :budget_order,
            :location_criterion
          ]
          unless no_customer_id.include?(service_name) or self.customer_id.present?
            raise "Adwords MCC #{service_name} request attempted without customer_id"
          end

          if self.adwords.config.read('authentication.auth_token').blank?
            # Adwords auth token not initialized
            self.request_auth_token
          end
        end

        begin
          @perform_retry = false
          @attempts += 1
          @service = self.service_init(service_name)
          if operation
            result = @service.send(method, operation)
          else
            result = @service.send(method)
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
          case @service_name
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

      def request_auth_token
        # Retrieve auth token
        auth_token = self.auth_token_storage
        unless auth_token
          puts 'Requesting new adwords token...'
          # Must unset adwords token
          Adstack::Config.unset(:auth_token)
          # Uses new adwordsapi instance
          auth_token = self.adwords.authorize
          # Deliver auth token
          self.auth_token_storage = auth_token
        end
        # Must recreate adwords instance
        Adstack::Config.set(auth_token: auth_token)
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
end
