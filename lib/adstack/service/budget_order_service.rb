module Adstack
  class BudgetOrderService < Service

    service_api :budget_order

    required :ad_group_id

    customer_id_free

    def selector
      super(:ad_group_id)
    end

  end
end
