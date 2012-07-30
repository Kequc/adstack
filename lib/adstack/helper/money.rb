module Adstack
  class Money < Helper

    ATTRIBUTES = [:micro_amount]
    attr_accessor *ATTRIBUTES

    def initialize(params={})
      params = { micro_amount: Toolkit.microfy(params) } unless params.is_a?(Hash)
      super(ATTRIBUTES, params.symbolize_all_keys)
    end

    def to_s
      self.in_units
    end

    def in_units
      Toolkit.largify(self.micro_amount)
    end

  end
end
