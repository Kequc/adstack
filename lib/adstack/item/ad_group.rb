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

    primary :id

    service_name :ad_group

    def perform_delete
      self.update_attributes(name: Toolkit.delete_name(self.name), status: 'DELETED')
    end

  end
end
