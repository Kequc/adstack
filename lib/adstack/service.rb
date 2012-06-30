module Adstack
  class Service < Api

    @search_params = {}

    def item(params={})
      nil
    end

    def find_operation
      nil
    end

    def response_location
      :entries
    end

    class << self

      def find(amount=:all, params={})
        return nil unless self.find_operation
        params.symbolize_all_keys!

        @required.each do |attribute|
          raise ArgumentError, "Missing parameter #{attribute}" unless params[attribute]
        end

        @search_params = params.slice(*self.item.filterable)

        response = self.find_operation
        response = items_from(response, *Array.wrap(self.response_location))

        return response.first if amount == :first
        response
      end

      def required(*symbols)
        @required = symbols
      end

    end

    def items_from(response, *symbols)
      response.symbolize_all_keys!

      response.widdle(*symbols).map { |a| self.item(a) }
    end

    def new_from_symbol(symbol, params={})
      eval(symbol.to_s.camelize).new(params)
    end

    def new_from(params, *symbols)
      return nil unless kind = params.widdle(*symbols)
      return nil unless Toolkit.find_in(self.item.kinds, kind)
      new_from_symbol(kind, params)
    end

    def selector(name=nil)
      Toolkit.selector(self.item.selectable, name)
    end

    def predicates(params={})
      Toolkit.predicates(self.item.filterable, params.merge(@search_params))
    end

  end
end
