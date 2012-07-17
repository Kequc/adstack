require 'adwords_api'
require 'active_model'
require 'yaml'
require 'erb'

require 'hash_patches'

require 'adstack/toolkit'
require 'adstack/config'

require 'adstack/helper'
require 'adstack/helper/address'
require 'adstack/helper/money'
require 'adstack/helper/budget'
require 'adstack/helper/geo_point'
require 'adstack/helper/geo_location'

require 'adstack/api'
require 'adstack/api/geo_location_service'
require 'adstack/api/location_id_service'
require 'adstack/api/report_service'

require 'adstack/service'
require 'adstack/service/account_service'
require 'adstack/service/customer_service'
require 'adstack/service/campaign_service'
require 'adstack/service/campaign_criterion_service'
require 'adstack/service/ad_group_service'
require 'adstack/service/budget_order_service'
require 'adstack/service/ad_extension_service'
require 'adstack/service/ad_group_criterion_service'
require 'adstack/service/ad_service'

require 'adstack/item'
require 'adstack/item/account'
require 'adstack/item/customer'
require 'adstack/item/campaign'
require 'adstack/item/campaign_criterion'
require 'adstack/item/campaign_criterion/location'
require 'adstack/item/campaign_criterion/platform'
require 'adstack/item/campaign_criterion/proximity'
require 'adstack/item/ad_group'
require 'adstack/item/budget_order'
require 'adstack/item/ad_group_criterion'
require 'adstack/item/ad_group_criterion/keyword'
require 'adstack/item/ad_extension'
require 'adstack/item/ad_extension/location_extension'
require 'adstack/item/ad_extension/mobile_extension'
require 'adstack/item/ad'
require 'adstack/item/ad/text_ad'

HTTPI.adapter = :curb
HTTPI.log = false # Supress HTTPI output

module Adstack
  API_VERSION = :v201109_1
  MCC = true
end
