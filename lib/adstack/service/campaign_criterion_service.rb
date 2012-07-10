module Adstack
  class CampaignCriterionService < Service

    service_api :campaign_criterion

    required :campaign_id

    def selector
      super(:ad_group_id)
    end

  end
end
