module Adstack
  class GeoPoint < Helper

    ATTRIBUTES = [:latitude, :longitude]
    attr_accessor *ATTRIBUTES

    def initialize(params={})
      params.symbolize_all_keys!
      params[:latitude] ||= params[:latitude_in_micro_degrees]
      params[:longitude] ||= params[:longitude_in_micro_degrees]
      super(ATTRIBUTES, params)
    end

    def writeable_attributes
      { latitude_in_micro_degrees: self.latitude, longitude_in_micro_degrees: self.longitude }
    end

  end
end
