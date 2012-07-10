module Adstack
  class Budget < Helper

    ATTRIBUTES = [:period, :amount, :delivery_method]
    attr_accessor *ATTRIBUTES

    def initialize(params={})
      params.symbolize_all_keys!
      super(ATTRIBUTES, { period: 'DAILY', delivery_method: 'STANDARD' }.merge(params))
    end

    def writeable_attributes
      result = self.attributes

      unless result[:amount].is_a?(Hash)
        result[:amount] = { micro_amount: Toolkit.microfy(@amount) }
      end

      result
    end

  end
end
