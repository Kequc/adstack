module Adstack
  class Proximity < CampaignCriterion

    field :geo_point,             :s,           e: :criterion, h: GeoPoint
    field :radius_in_units,       :roc, :s,     e: :criterion
    field :radius_distance_units, :roc, :s,     e: :criterion, w: %w{KILOMETERS MILES}
    field :address,               :s,           e: :criterion, h: Address

    kind :proximity

    def initialize(params={})
      params.symbolize_all_keys!

      if params[:radius]
        radius = params.delete(:radius).split(" ")

        params[:radius_in_units]        ||= radius[0]
        params[:radius_distance_units]  ||= radius[1]
      end

      super(params)
    end

  end
end
