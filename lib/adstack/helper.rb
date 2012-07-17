module Adstack
  class Helper

    def initialize(symbols, params={})
      params.symbolize_all_keys!
      @all_attributes = symbols
      self.set_attributes(params)
    end

    def set_attributes(params={})
      @all_attributes.each do |symbol|
        value = params[symbol]
        begin
          self.send("#{symbol}=", value)
        rescue
          instance_variable_set("@#{symbol}", value)
        end
      end
    end

    def attributes(for_output=false)
      result = {}
      method_name = for_output ? :writeable_attributes : :attributes
      @all_attributes.each do |symbol|
        next unless self.respond_to?(symbol)
        value = self.send(symbol)
        if !value.is_a?(String) and value.respond_to?(method_name)
          value = value.send(method_name)
        end
        result[symbol] = value
      end
      result
    end

    def writeable_attributes
      self.attributes(true)
    end

  end
end
