module Adstack
  class AdGroupKeyword < AdGroupCriterion
    include Keyword

    kind :ad_group_keyword, r: :keyword

    can_batch

  end
end
