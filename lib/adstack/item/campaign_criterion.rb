module Adstack
  class CampaignCriterion < Item

    field :campaign_id,     :f, :r, :s
    field :is_negative,     :f, :ro, :s

    service_api :campaign_criterion

    parent :campaign

    cannot_update

    kind_lookup :criteria_type, :criterion, :criterion_type

  end
end
