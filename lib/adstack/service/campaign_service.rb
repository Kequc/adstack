module Adstack
  class CampaignService < Service

    service_name :campaign

    def item(params={})
      Account.new(params)
    end

    def perform_find
      get(self.selector(:name), self.predicates(status: %w{ACTIVE PAUSED}))
    end

  end
end
