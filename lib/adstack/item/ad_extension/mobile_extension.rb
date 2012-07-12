module Adstack
  class MobileExtension < AdExtension

    field :phone_number,          :r, :s, e: :ad_extension, l: [3, 30]
    field :country_code,          :r, :s, e: :ad_extension, l: [2, 2]
    field :is_call_only,              :s, e: :ad_extension, d: false

    kind :mobile_extension

    def delete_operation
      result = super
      result[:ad_extension].merge!(country_code: self.country_code, phone_number: self.phone_number)
      result
    end

    def writeable_attributes(list=nil)
      result = super(list)
      result[:ad_extension].merge!(xsi_type: 'MobileExtension')
      result
    end

  end
end
