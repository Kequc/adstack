module Adstack
  class LocationExtension < AdExtension

    field :address,           :r, :s,   e: :ad_extension, h: Address
    field :geo_point,         :r, :s,   e: :ad_extension, h: GeoPoint
    field :encoded_location,  :r, :s,   e: :ad_extension
    field :company_name,      :s,       e: :ad_extension, l: [1, 80]
    field :phone_number,      :s,       e: :ad_extension

    kind :location_extension

    def writeable_attributes(list=nil)
      result = super(list)
      result[:ad_extension].merge!(source: 'ADWORDS_FRONTEND')
      # Ad extension service doesn't support province_code in address
      result[:ad_extension][:address][:province_name] ||= result[:ad_extension][:address].delete(:province_code) rescue nil
      result
    end

  end
end
