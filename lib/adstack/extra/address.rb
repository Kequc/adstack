module Adstack
  class Address

    ATTRIBUTES = [:street_address, :street_address2, :city, :region, :country, :postal]
    attr_accessor *ATTRIBUTES

    def initialize(params=nil)
      # Params sometimes passed into this method as nil
      params ||= {}
      params.symbolize_all_keys!

      # Account for adwords formatted input
      params[:city] ||= params[:city_name]
      params[:region] ||= params[:province_code] || params[:province_name]
      params[:postal] ||= params[:postal_code]
      params[:country] ||= params[:country_code]

      ATTRIBUTES.each do |attribute|
        value = params[attribute]
        instance_variable_set("@#{attribute}", value) if value
      end
    end

    def attributes
      result = {}
      ATTRIBUTES.each do |attribute|
        result[attribute] = self.send(attribute)
      end
      result
    end

    def attributes_for_adwords
      result = {
        street_address: @street_address,
        street_address2: @street_address2,
        city_name: @city,
        province_code: nil,
        province_name: @region,
        postal_code: @postal,
        country_code: @country
      }

      if @region.to_s.size == 2
        result[:province_name] = nil
        result[:province_code] = @region
      end

      result.except_blank
    end

  end
end
