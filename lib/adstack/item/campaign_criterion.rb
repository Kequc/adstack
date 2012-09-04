module Adstack
  class CampaignCriterion < Item
    include Adstack::Deleteable

    field :campaign_id,     :f, :r, :s
    field :is_negative,     :f, :ro, :s

    field :id,              :f, :ro, :s, e: :criterion

    service_api :campaign_criterion

    parent :campaign

    kind_lookup :criteria_type, :criterion, :criterion_type

  end
end
