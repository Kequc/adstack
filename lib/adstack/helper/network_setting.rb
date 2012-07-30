module Adstack
  class NetworkSetting < Helper

    ATTRIBUTES = [:google_search, :search_network, :content_network, :partner_search_network]
    attr_accessor *ATTRIBUTES

    def initialize(params={})
      params.symbolize_all_keys!
      ATTRIBUTES.each do |symbol|
        params[symbol] = params.delete("target_#{symbol}".to_sym) if params[symbol].nil?
        # Store as boolean true by default
        params[symbol] = true if params[symbol].nil?
        params[symbol] = !!params[symbol]
      end
      super(ATTRIBUTES, params)
    end

    def writeable_attributes
      params = super
      result = {}
      ATTRIBUTES.each do |symbol|
        result["target_#{symbol}".to_sym] = params[symbol]
      end
      result
    end

  end
end
