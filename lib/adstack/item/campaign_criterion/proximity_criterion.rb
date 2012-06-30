module Adstack
  class ProximityCriterion < CampaignCriterion

    field :geo_point,       :s,           e: :criterion
    field :radius_distance_units, :r, :s, e: :criterion
    field :radius_in_units, :r, :s,       e: :criterion
    field :address,         :s,           e: :criterion

  end
end
