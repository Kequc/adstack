module Adstack
  class AccountService < Service

    service_api :serviced_account, r: :account, l: :accounts

    customer_id_free

    def self.find(amount=:all, params={})
      result = super(:all, params)
      customer_ids = Array.wrap(params[:customer_ids])
      unless customer_ids.empty?
        result = result.select {|a| customer_ids.include?(a.customer_id)}
      end
      result = result.first if amount == :first
      result = result.sample if amount == :sample
      result
    end

    def selector
    end

    def predicates
    end

  end
end
