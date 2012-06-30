module Adstack
  class CampaignCriterionService < Service

    required :campaign_id

    service_name :campaign_criterion

    def item(params={})
      new_from(params, :criterion, :criterion_type)
    end

    def perform_find
      get(self.selector(:ad_group_id), self.predicates)
    end

  end
end
