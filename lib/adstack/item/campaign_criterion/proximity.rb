module Adstack
  class Proximity < CampaignCriterion

    field :id,                    :f, :ro, :s,  e: :criterion
    field :geo_point,             :s,           e: :criterion, h: GeoPoint
    field :radius_in_units,       :roc, :s,     e: :criterion
    field :radius_distance_units, :roc, :s,     e: :criterion, w: %w{KILOMETERS MILES}
    field :address,               :s,           e: :criterion, h: Address

    kind :proximity

    def initialize(params={})
      params.symbolize_all_keys!

      if params[:radius]
        radius = params.delete(:radius).split(" ")
        params[:radius_distance_in_units] ||= radius[0]
        params[:radius_distance_units] ||= radius[1]
      end

      super(params)
    end

    def writeable_attributes(list=nil)
      result = super(list)
      result[:criterion] ||= {}
      result[:criterion].merge!(xsi_type: 'Proximity')
      result
    end

  end
end
