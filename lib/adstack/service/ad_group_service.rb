module Adstack
  class AdGroupService < Service

    required :campaign_id

    service_name :ad_group

    def item(params={})
      AdGroup.new(params)
    end

    def perform_find
      get(self.selector(:name), self.predicates(status: %w{ACTIVE PAUSED}))
    end

  end
end
