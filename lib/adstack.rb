require 'adwords_api'
require 'yaml'

require './adapi/common'
require './adapi/version'
require './adapi/config'

require './hash.rb'

require './httpi_request_monkeypatch'

HTTPI.adapter = :curb
HTTPI.log = false # Supress HTTPI output

module Adapi
  API_VERSION = :v201109_1
  MCC = true
end
