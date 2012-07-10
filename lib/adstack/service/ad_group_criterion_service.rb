module Adstack
  class AdGroupCriterionService < Service

    service_api :ad_group_criterion

    required :ad_group_id

    def selector
      super(:ad_group_id)
    end

  end
end
