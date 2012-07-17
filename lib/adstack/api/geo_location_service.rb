module Adstack
  class GeoLocationService < Api

    attr_accessor :addresses

    service_api :geo_location

    customer_id_free

    def initialize(addresses)
      addresses = Array.wrap(addresses).map &:symbolize_all_keys
      # Format addresses
      self.addresses = addresses.map { |address| Address.new(address) }
    end

    def self.find(addresses)
      # Am I looking for one address or many
      amount = addresses.is_a?(Array) ? :all : :first

      # Return list
      locations = new(addresses).perform_find || []
      locations.map! do |location|
        location.symbolize_all_keys!
        if location[:geo_location_type] == "InvalidGeoLocation"
          nil
        else
          self.item(location)
        end
      end

      return locations.first if amount == :first
      locations
    end

    # Find it
    def perform_find
      get(addresses: self.addresses.map(&:writeable_attributes))
    end

  end
end
