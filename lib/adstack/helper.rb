module Adstack
  class Helper

    attr_accessor :all_attributes

    def initialize(symbols, params={})
      params.symbolize_all_keys!
      self.all_attributes = symbols
      self.set_attributes(params)
    end

    def set_attributes(params={})
      self.all_attributes.each do |symbol|
        value = params[symbol]
        instance_variable_set("@#{symbol}", value) if value
      end
    end

    def attributes
      result = {}
      self.all_attributes.each do |symbol|
        result[symbol] = self.send(symbol)
      end
      result
    end

    alias_method :writeable_attributes, :attributes

  end
end
