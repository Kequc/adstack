module Adstack
  class AccountService < Service

    service_name :serviced_account

    def item(params={})
      Account.new(params)
    end

    def perform_find
      get
    end

    def self.find(amount=:all)
      response = self.perform_find
      response = items_from(response, *Array.wrap(self.response_location))

      return response.sample if amount == :sample
      response
    end

    def response_location
      :accounts
    end

  end
end
