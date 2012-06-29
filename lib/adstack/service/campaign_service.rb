module Adstack
  class CampaignService < Service

    def item(params={})
      Account.new(params)
    end

    def find_operation
      Api.get(:campaign, self.selector(:name), self.predicates(status: %w{ACTIVE PAUSED}))
    end

  end
end
