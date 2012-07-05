module Adstack
  class LocationId < Api

    service_api :location_criterion, :c

    def item(params={})
      params[:location][:id]
    end

    # LocationId.find(:city => 'Prague')
    # LocationId.find(:country => 'CZ', :city => 'Prague')
    # LocationId.find(:country => 'CZ', :region => 'Prague' :city => 'Prague')
    #
    def self.find(params={})
      params.symbolize_all_keys!

      # Determine which criteria are we searching for
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

      locations = get(selector, predicates) || []
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
