module Adstack
  class AdExtension < Item
    include Adstack::Updateable
    include Adstack::Deleteable

    field :campaign_id,       :f, :r, :s
    field :status,            :f, :s,       w: %w{ACTIVE DELETED}
    field :approval_status,   :f, :ro, :s,  w: %w{APPROVED UNCHECKED DISAPPROVED}
    field :stats,             :ro

    field :id,                :f, :ro, :s,  e: :ad_extension, lu: :ad_extension_id

    service_api :campaign_ad_extension, r: :ad_extension

    parent :campaign

    kind_lookup :ad_extension_type, :ad_extension, :ad_extension_type

  end
end
