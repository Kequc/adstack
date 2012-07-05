module Adstack
  class PlatformCriterion < CampaignCriterion

    field :platform_name, :ro, :s, e: :criterion

    kind :campaign_criterion

  end
end
