module Adstack
  class Proximity < CampaignCriterion

    field :geo_point,             :s,       e: :criterion, h: GeoPoint
    field :radius_distance_units, :roc, :s, e: :criterion, w: %w{KILOMETERS MILES}
    field :radius_in_units,       :roc, :s, e: :criterion
    field :address,               :s,       e: :criterion, h: Address

    kind :proximity, :s

    def writeable_attributes(list=nil)
      result = super(list)
      result[:criterion].merge!(xsi_type: 'Proximity')
      result
    end

  end
end
