module Adstack
  class BudgetOrderService < Service

    service_api :budget_order

    def initialize(params={})
      super({billing_account_id: Config.get(:billing_account_id)}.merge(params))
    end

  end
end
