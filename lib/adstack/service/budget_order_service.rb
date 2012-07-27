module Adstack
  class BudgetOrderService < Service

    service_api :budget_order

    def initialize(params={})
      super({billing_account_id: Config.get(:billing_account_id)}.merge(params))
    end

    def self.find(amount=:all, params={})
      budget_orders = super(amount, params)
      return budget_orders unless amount == :current

      # Find currently active budget_order
      if amount == :current
        budget_orders.each do |budget_order|
          if budget_order.is_current?
            return budget_order
          end
        end
      end

      nil
    end

  end
end
