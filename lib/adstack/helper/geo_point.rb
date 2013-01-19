module Adstack
  class GeoPoint < Helper

    ATTRIBUTES = [:latitude, :longitude]
    attr_accessor *ATTRIBUTES

    def initialize(params={})
      params.symbolize_all_keys!
      params[:latitude] ||= Adstack::Toolkit.largify(params[:latitude_in_micro_degrees])
      params[:longitude] ||= Adstack::Toolkit.largify(params[:longitude_in_micro_degrees])
      super(ATTRIBUTES, params)
    end

    def writeable_attributes
      {
        latitude_in_micro_degrees: Adstack::Toolkit.microfy(latitude),
        longitude_in_micro_degrees: Adstack::Toolkit.microfy(longitude)
      }
    end

  end
end
