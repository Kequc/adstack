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
      params.symbolize_keys!
      params[:billing_account_id] ||= Config.get(:billing_account_id)
      params[:start_date_time] ||= Time.now+60
      super(params)
    end

    def end_immediately
      self.update_attributes(end_date_time: Time.now+30) if self.end_date_time > Time.now+30
    end

  end
end
