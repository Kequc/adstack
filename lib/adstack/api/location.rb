module Adstack
  class Location < Api

    def item(params={})
      params[:location][:id]
    end

    # LocationService.find(:city => 'Prague')
    # LocationService.find(:country => 'CZ', :city => 'Prague')
    # LocationService.find(:country => 'CZ', :region => 'Prague' :city => 'Prague')
    #
    def self.find(params={})
      params.symbolize_all_keys!

      # Determine by which criteria are we searching
      location_type = nil
      [:city, :region, :country].each do |symbol|
        if params[symbol].present?
          location_type = symbol
          break
        end
      end
      return nil unless location_type
      
      predicates = Toolkit.predicates([:location_name], { location_name: params[symbol] })
      selector = Toolkit.selector([:id, :location_name, :display_type])

      locations = Api.get(:location_criterion, selector, predicates) || []
      location_id = nil
      locations.each do |location|
        if location[:location][:display_type] == location_type.to_s.capitalize
          location_id = self.item(location)
          break
        end
      end

      location_id
    end

  end
end
