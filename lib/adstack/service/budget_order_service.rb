module Adstack
  class BudgetOrderService < Service

    required :ad_group_id, :criteria_type

    def item(params={})
      BudgetOrder.new(params)
    end

    def find_operation
      Api.get(:budget_order, self.selector(:ad_group_id), self.predicates)
    end

  end
end
