module Adstack
  class AdGroupCriterionService < Service

    required :ad_group_id, :criteria_type

    parents :keyword

    def item(params={})
      new_from(params, :criterion, :criteria_type)
    end

    def find_operation
      Api.get(:ad_group_criterion, self.selector(:ad_group_id), self.predicates)
    end

  end
end
