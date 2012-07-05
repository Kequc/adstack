module Adstack
  class CampaignService < Service

    service_api :campaign

    def selector
      super(:name)
    end

    def predicates
      super(status: %w{ACTIVE PAUSED})
    end

  end
end
