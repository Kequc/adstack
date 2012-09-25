module Adstack
  class CampaignKeyword < CampaignCriterion
    include Keyword

    kind :campaign_keyword, r: :keyword

    can_batch

  end
end
