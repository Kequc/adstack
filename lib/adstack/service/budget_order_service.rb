module Adstack
  class BudgetOrderService < Service

    service_api :budget_order

    required :billing_account_id

  end
end
