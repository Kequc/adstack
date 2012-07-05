module Adstack
  class AccountService < Service

    service_api :serviced_account, r: :account, l: :accounts

    customer_id_free

    def self.find(amount=:all)
      response = new.perform_find

      return response.sample if amount == :sample
      response
    end

    def selector
    end

    def predicates
    end

  end
end
