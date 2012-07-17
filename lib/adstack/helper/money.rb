module Adstack
  class Money < Helper

    ATTRIBUTES = [:micro_amount]
    attr_accessor *ATTRIBUTES

    def initialize(params={})
      params = { micro_amount: Toolkit.microfy(params) } unless params.is_a?(Hash)
      super(ATTRIBUTES, params.symbolize_all_keys)
    end

  end
end
