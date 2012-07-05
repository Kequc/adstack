module Adstack
  class Ad < Item

    field :ad_group_id,       :f, :r, :s
    field :experiment_data
    field :status,            :f, :r, :s, w: %w{ENABLED PAUSED DISABLED}
    field :stats,             :ro

    field :id,                :f, :ro, :s,  e: :ad
    field :url,               :f, :s,       e: :ad
    field :display_url,       :f, :s,       e: :ad
    field :disapproval_reasons,   :ro, :s,  e: :ad
    field :ad_type,               :ro,      e: :ad

    service_api :ad_group_ad, r: :ad

    parent :ad_group

    def delete_operation
      { ad_group_id: self.ad_group_id, ad: { id: self.id } }
    end

  end
end
