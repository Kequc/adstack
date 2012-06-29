module Adstack
  class Service < Api

    def item(params={})
      nil
    end

    def find_operation
      nil
    end

    def response_location
      :entries
    end

    def parents
      @parents || []
    end

    def search_params
      @search_params || {}
    end

    class << self

      def find(amount=:all, params={})
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

      def parents(*symbols)
        @parents = symbols
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
      return nil unless Toolkit.find_in(self.parents, kind)
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
