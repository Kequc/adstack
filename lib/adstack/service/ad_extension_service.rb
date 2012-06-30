module Adstack
  class AdExtensionService < Service

    required :campaign_id

    service_name :campaign_ad_extension

    def item(params={})
      new_from(params, :ad_extension, :ad_extension_type)
    end

    def perform_find
      get(self.selector(:ad_extension_id), self.predicates)
    end

  end
end
