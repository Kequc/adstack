module Adstack
  class AccountService < Service

    service_api :serviced_account, r: :account, l: :accounts

    customer_id_free

    def selector
    end

    def predicates
    end

  end
end
