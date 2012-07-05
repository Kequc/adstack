module Adstack
  class AdGroup < Item

    field :id,            :f, :ro, :s
    field :campaign_id,   :f, :r, :s
    field :campaign_name, :f, :ro, :s
    field :name,          :f, :s
    field :status,        :f, :s, w: %w{ENABLED PAUSED DELETED}
    field :bids
    field :experiment_data
    field :stats

    service_api :ad_group

    cannot_delete :set_status

    parent :campaign

    children :ad_group_criterion, :budget_order, :ad

    def child_attributes
      super(ad_group_id: self.id)
    end

  end
end
