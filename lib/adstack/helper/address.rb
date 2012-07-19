module Adstack
  class Address < Helper

    ATTRIBUTES = [:street_address, :street_address2, :city, :region, :country, :postal]
    attr_accessor *ATTRIBUTES

    def initialize(params=nil)
      # Params sometimes passed into this method as nil
      params ||= {}
      params.symbolize_all_keys!

      # Account for adwords formatted input
      params[:city] ||= params[:city_name]
      params[:region] ||= params[:province_name] || params[:province_code]
      params[:postal] ||= params[:postal_code]
      params[:country] ||= params[:country_code]

      super(ATTRIBUTES, params)
    end

    def writeable_attributes
      result = {
        street_address: @street_address,
        street_address2: @street_address2,
        city_name: @city,
        province_name: @region,
        postal_code: @postal,
        country_code: @country
      }

      result.except_blank
    end

  end
end
