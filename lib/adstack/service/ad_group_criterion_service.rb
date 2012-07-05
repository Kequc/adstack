module Adstack
  class AdGroupCriterionService < Service

    service_api :ad_group_criterion

    required :ad_group_id, :criteria_type

    kinds :keyword

    kinds_locator :criterion, :criterion_type

    def selector
      super(:ad_group_id)
    end

  end
end
