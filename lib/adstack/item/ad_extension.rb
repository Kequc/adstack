module Adstack
  class AdExtension < Item

    field :campaign_id,       :f, :r, :s
    field :status,            :f, :s, w: %w{ACTIVE DELETED}
    field :approval_status,   :f, :s, w: %w{APPROVED UNCHECKED DISAPPROVED}
    field :stats,             :ro

    field :id,                :f, :s, e: :ad_extension
    field :ad_extension_type, :ro,    e: :ad_extension

    primary :id

    service_name :campaign_ad_extension

    kinds :location_extension, :mobile_extension

    def perform_delete
      self.update_attributes(name: Toolkit.delete_name(self.name), status: 'DELETED')
    end

    def activate
      self.update_attributes(status: 'ACTIVE')
    end

  end
end
