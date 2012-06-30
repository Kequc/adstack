module Adstack
  class BudgetOrderService < Service

    required :ad_group_id, :criteria_type

    service_name :budget_order

    def item(params={})
      BudgetOrder.new(params)
    end

    def perform_find
      get(self.selector(:ad_group_id), self.predicates)
    end

  end
end
