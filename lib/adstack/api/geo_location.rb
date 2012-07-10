module Adstack
  class GeoLocation < Api

    service_api :geo_location

    def item(params={})
      Address.new(params)
    end

    def self.find(addresses)
      # Am I looking for one address or many
      amount = addresses.is_a?(Array) ? :all : :first

      # Format addresses
      addresses = Array.wrap(addresses).map { |address| self.item(address).writeable_attributes }

      # Return list of GeoLocations
      locations = get(addresses: addresses) || []
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
