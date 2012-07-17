module Adstack
  class LocationIdService < Api

    ATTRIBUTES = [:city, :region, :country]
    attr_accessor *ATTRIBUTES

    service_api :location_criterion

    customer_id_free

    def item(params={})
      params[:location][:id] rescue nil
    end

    def initialize(params={})
      # Get address
      Address.new(params).attributes.slice(*ATTRIBUTES).each_pair do |key, value|
        self.send("#{key}=", value)
      end
    end

    # LocationId.find(:city => 'Prague')
    # LocationId.find(:country => 'CZ', :city => 'Prague')
    # LocationId.find(:country => 'CZ', :region => 'Prague' :city => 'Prague')
    #
    def self.find(params={})
      params.symbolize_all_keys!

      # Determine which criteria are we searching for
      lis = new(params)
      return nil unless lis.location_type
      
      # Lookup results and find best match for intended search type
      locations = lis.perform_find || []
      locations.each do |location|
        if location[:location][:display_type] == Toolkit.adw(lis.location_type)
          return self.item(location)
        end
      end
      nil
    end

    # Order of specificity
    def location_type
      ATTRIBUTES.each do |symbol|
        return symbol if self.send(symbol).present?
      end
      nil
    end

    # Find it
    def perform_find
      get(self.selector, self.predicates)
    end

    def predicates
      Toolkit.predicates([:location_name], { location_name: self.send(self.location_type) })
    end

    def selector
      Toolkit.selector([:id, :location_name, :display_type])
    end

    def attributes
      {
        city: self.city,
        region: self.region,
        country: self.country
      }
    end

    alias_method :writeable_attributes, :attributes

  end
end
