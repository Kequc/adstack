module Adstack
  class Budget < Helper

    ATTRIBUTES = [:period, :amount, :delivery_method]
    attr_accessor *ATTRIBUTES

    def initialize(params={})
      params = { amount: params } unless params.is_a?(Hash)
      params.symbolize_all_keys!
      super(ATTRIBUTES, { period: 'DAILY', delivery_method: 'STANDARD' }.merge(params))
    end

    def amount=(params={})
      @amount = Money.new(params)
    end

  end
end
