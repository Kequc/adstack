module Adstack
  class AdGroupService < Service

    service_api :ad_group

    required :campaign_id

    def selector
      super(:name)
    end

    def predicates
      super(status: %w{ENABLED PAUSED})
    end

  end
end
