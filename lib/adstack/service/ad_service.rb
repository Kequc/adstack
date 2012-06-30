module Adstack
  class AdService < Service

    required :ad_group_id

    service_name :ad_group_ad

    def item(params={})
      new_from(params, :ad, :ad_type)
    end

    def perform_find
      get(self.selector(:name), self.predicates)
    end

  end
end
