module Adstack
  class Ad < Item

    field :ad_group_id,       :less, :f, :r, :s
    field :experiment_data,   :less
    field :status,            :less, :f, :r, :s, w: %w{ENABLED PAUSED DISABLED}
    field :stats,             :less, :ro

    field :id,                :f, :ro, :s
    field :url,               :f, :s
    field :display_url,       :f, :s
    field :approval_status,   :f, :ro, :s
    field :disapproval_reasons,   :ro, :s
    field :trademark_disapproved, :ro, :s
    field :ad_type,           :ro

    primary :id

    def writeable_attributes
      # This is a layered class
      self.writeable_attributes(true).merge(ad: super)
    end

    def save_operation
      Api.mutate_explicit(:ad_group_ad, self.o, self.writeable_attributes)
    end

    def delete_operation
      Api.mutate_explicit(:ad_group_ad, 'REMOVE', { ad_group_id: self.ad_group_id, ad: { id: self.id } })
    end

  end
end
