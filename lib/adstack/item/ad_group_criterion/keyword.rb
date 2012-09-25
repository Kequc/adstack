module Adstack
  class AdGroupKeyword < AdGroupCriterion
    include Keyword

    kind :ad_group_keyword, r: :keyword

    can_batch

    def self.positive_xsi_type
      "Biddable#{super}"
    end

  end
end
