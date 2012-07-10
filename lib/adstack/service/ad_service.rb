module Adstack
  class AdService < Service

    service_api :ad_group_ad, r: :ad

    required :ad_group_id

  end
end
