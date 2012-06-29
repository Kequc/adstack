module Adstack
  class GeoLocation < Api

    def item(params={})
      Address.new(params)
    end

    def self.find(addresses)
      # Am I looking for one address or many
      amount = addresses.is_a?(Array) ? :all : :first

      # Format addresses
      addresses = Array.wrap(addresses).map { |address| Address.new(address).attributes_for_adwords }

      # Return list of GeoLocations
      locations = Api.get(:geo_location, { addresses: addresses }) || []
      locations.map! do |location|
        if location[:geo_location_type] == "InvalidGeoLocation"
          nil
        else
          self.item(location[:address])
        end
      end

      return locations.first if amount == :first
      locations
    end

  end
end
