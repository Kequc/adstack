module Adstack
  class CampaignCriterion < Item

    field :campaign_id,     :f, :r, :s
    field :is_negative,     :f, :ro, :s
    field :bid_modifier,    :f, :s, r: [0.1, 10.0]

    field :id,              :f, :s,       e: :criterion
    field :type,            :f, :ro, :s,  e: :criterion
    field :criterion_type,  :ro,          e: :criterion

    service_api :campaign_criterion

    parent :campaign

  end
end
