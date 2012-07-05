module Adstack
  class LocationExtension < AdExtension

    field :address,         :s,     e: :ad_extension
    field :geo_point,       :s,     e: :ad_extension
    field :encoded_location, :s,    e: :ad_extension
    field :company_name,    :s,     e: :ad_extension, l: [1, 80]
    field :phone_number,    :s,     e: :ad_extension
    field :source,          :f, :s, e: :ad_extension
    field :icon_media_id,   :s,     e: :ad_extension
    field :image_media_id,  :s,     e: :ad_extension

    kind :ad_extension

  end
end
