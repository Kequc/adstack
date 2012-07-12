module Adstack
  class BudgetOrder < Item

    field :billing_account_id,  :f, :r, :s
    field :id,                  :f, :s
    field :spending_limit,      :f, :r, :s
    field :start_date_time,     :f, :r, :s
    field :end_date_time,       :f, :r, :s

    service_api :budget_order

    # parent :ad_group

  end
end
