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

    def save_operation
      Api.mutate_explicit(:ad_group, self.o, self.writeable_attributes)
    end

    def delete_operation
      self.update_attributes(name: Toolkit.delete_name(self.name), status: 'DELETED')
    end

  end
end
