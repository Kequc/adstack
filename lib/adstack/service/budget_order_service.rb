module Adstack
  class BudgetOrderService < Service

    service_api :budget_order

    required :billing_account_id

    customer_id_free

    def selector
      super(:ad_group_id)
    end

  end
end
