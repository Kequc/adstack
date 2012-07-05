module Adstack
  class MobileExtension < AdExtension

    field :phone_number, :r, :s,          e: :ad_extension, l: [3, 30]
    field :country_code, :r, :s,          e: :ad_extension, l: [2, 2]
    field :is_call_tracking_enabled,  :s, e: :ad_extension
    field :is_call_only, :s,              e: :ad_extension

    kind :ad_extension

  end
end
