module Adstack
  class Ad < Item

    field :ad_group_id,       :f, :r, :s
    field :experiment_data
    field :status,            :f, :r, :s, w: %w{ENABLED PAUSED DISABLED}
    field :stats,             :ro

    field :id,                :f, :ro, :s, e: :ad
    field :url,               :f, :s, e: :ad
    field :display_url,       :f, :s, e: :ad
    field :approval_status,   :f, :ro, :s, e: :ad
    field :disapproval_reasons,   :ro, :s, e: :ad
    field :trademark_disapproved, :ro, :s, e: :ad
    field :ad_type,           :ro, e: :ad

    primary :id

    service_name :ad_group_ad

    kinds :text_ad

    def delete_operation
      { ad_group_id: self.ad_group_id, ad: { id: self.id } }
    end

  end
end
