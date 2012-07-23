module Adstack
  class BudgetOrder < Item

    field :billing_account_id,  :f, :roc, :s
    field :id,                  :f, :s
    field :spending_limit,      :f, :roc, :s, h: Money
    field :start_date_time,     :f, :roc, :s, t: :timezone
    field :end_date_time,       :f, :roc, :s, t: :timezone

    service_api :budget_order

    parent :account

    def initialize(params={})
      super({billing_account_id: Config.get(:billing_account_id)}.merge(params))
    end

  end
end
