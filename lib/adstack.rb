require 'adwords_api'
require 'active_model'
require 'yaml'
require 'erb'

require './hash.rb'
require './httpi_monkeypatch'

require './adstack/toolkit'
require './adstack/config'
require './adstack/extra/address'

require './adstack/api'
require './adstack/api/geo_location'
require './adstack/api/location_id'
require './adstack/api/report'

require './adstack/item'
require './adstack/item/account'
require './adstack/item/budget_order'
require './adstack/item/campaign'
require './adstack/item/campaign_criterion'
require './adstack/item/campaign_criterion/location_criterion'
require './adstack/item/campaign_criterion/platform_criterion'
require './adstack/item/campaign_criterion/proximity_criterion'
require './adstack/item/ad_group'
require './adstack/item/ad_group_criterion'
require './adstack/item/ad_group_criterion/keyword_criterion'
require './adstack/item/ad_extension'
require './adstack/item/ad_extension/location_extension'
require './adstack/item/ad_extension/mobile_extension'
require './adstack/item/ad'
require './adstack/item/ad/text_ad'

require './adstack/service'
require './adstack/service/account_service'
require './adstack/service/budget_order_service'
require './adstack/service/campaign_service'
require './adstack/service/campaign_criterion_service'
require './adstack/service/ad_group_service'
require './adstack/service/ad_extension_service'
require './adstack/service/ad_group_criterion_service'
require './adstack/service/ad_service'

HTTPI.adapter = :curb
HTTPI.log = false # Supress HTTPI output

module Adstack
  API_VERSION = :v201109_1
  MCC = true
end
