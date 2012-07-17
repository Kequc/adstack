module Adstack
  class GeoLocation < Helper

    ATTRIBUTES = [:geo_point, :address, :encoded_location]
    attr_accessor *ATTRIBUTES

    def initialize(params={})
      super(ATTRIBUTES, params.symbolize_all_keys)
    end

    def geo_point=(params={})
      @geo_point = GeoPoint.new(params)
    end

    def address=(params={})
      @address = Address.new(params)
    end

    def self.find(addresses)
      GeoLocationService.find(addresses)
    end

  end
end
