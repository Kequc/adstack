module Adstack
  class AdExtension < Item

    field :campaign_id,       :f, :r, :s
    field :status,            :f, :s, w: %w{ACTIVE DELETED}
    field :approval_status,   :f, :s, w: %w{APPROVED UNCHECKED DISAPPROVED}
    field :stats,             :ro

    field :id,                :f, :s, e: :ad_extension
    field :ad_extension_type, :ro,    e: :ad_extension

    service_api :campaign_ad_extension, r: :ad_extension

    cannot_delete :set_status

    parent :campaign

    def activate
      self.update_attributes(status: 'ACTIVE')
    end

  end
end
