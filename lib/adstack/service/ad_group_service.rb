module Adstack
  class AdGroupService < Service

    required :campaign_id

    def item(params={})
      AdGroup.new(params)
    end

    def find_operation
      Api.get(:ad_group, self.selector(:name), self.predicates(status: %w{ACTIVE PAUSED}))
    end

  end
end
