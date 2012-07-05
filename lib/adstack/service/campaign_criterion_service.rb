module Adstack
  class CampaignCriterionService < Service

    service_api :campaign_criterion

    required :campaign_id

    kinds :platform_criterion, :location_criterion, :proximity_criterion

    kinds_locator :criterion, :criterion_type

    def selector
      super(:ad_group_id)
    end

  end
end
