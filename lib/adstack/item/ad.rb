module Adstack
  class Ad < Item
    include Adstack::Deleteable

    field :ad_group_id,       :f, :r, :s
    field :status,            :f, :r, :s, d: "ENABLED", w: %w{ENABLED PAUSED DISABLED}
    field :stats,             :ro

    field :id,                :f, :ro, :s,  e: :ad
    field :url,               :f,  :s, :p,  e: :ad
    field :display_url,       :f,  :s, :p,  e: :ad
    field :disapproval_reasons,   :ro, :s,  e: :ad

    service_api :ad_group_ad, r: :ad

    parent :ad_group

    kind_lookup :ad_type, :ad, :ad_type

  end
end
