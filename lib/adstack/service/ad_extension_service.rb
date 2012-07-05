module Adstack
  class AdExtensionService < Service

    service_api :campaign_ad_extension, r: :ad_extension

    required :campaign_id

    kinds :location_extension, :mobile_extension

    kinds_locator :ad_extension, :ad_extension_type

    def selector
      super(:ad_extension_id)
    end

  end
end
