module Adstack
  class LocationCriterion < CampaignCriterion

    field :location_name,     :f, :ro, :s,  e: :criterion
    field :display_type,      :ro, :s,      e: :criterion
    field :targeting_status,  :ro, :s,      e: :criterion
    field :parent_locations,  :ro, :s,      e: :criterion

    kind :campaign_criterion

  end
end
