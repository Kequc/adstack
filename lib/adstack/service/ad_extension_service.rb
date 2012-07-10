module Adstack
  class AdExtensionService < Service

    service_api :campaign_ad_extension, r: :ad_extension

    required :campaign_id

    def selector
      super(:ad_extension_id)
    end

    def predicates
      super(status: %w{ACTIVE})
    end

  end
end
