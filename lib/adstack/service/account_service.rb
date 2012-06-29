module Adstack
  class AccountService < Service

    def item(params={})
      Account.new(params)
    end

    def find_operation
      Api.get(:serviced_account)
    end

    def response_location
      :accounts
    end

    def self.find(amount=:all)
      response = self.find_operation
      response = items_from(response, *Array.wrap(self.response_location))

      return response.sample if amount == :sample
      response
    end

  end
end
