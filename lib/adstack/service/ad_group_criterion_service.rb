module Adstack
  class AdGroupCriterionService < Service

    required :ad_group_id, :criteria_type

    service_name :ad_group_criterion

    def item(params={})
      new_from(params, :criterion, :criteria_type)
    end

    def perform_find
      get(self.selector(:ad_group_id), self.predicates)
    end

  end
end
