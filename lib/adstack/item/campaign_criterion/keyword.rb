module Adstack
  class CampaignKeyword < CampaignCriterion
    include Adstack::Keyword

    kind :campaign_keyword, r: :keyword

    can_batch

  end
end
