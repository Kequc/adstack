module Adstack
  class Service < Api

    @search_params = {}

    def item(params={})
      nil
    end

    class << self

      def find(amount=:all, params={})
        return nil unless self.perform_find
        params.symbolize_all_keys!

        Array.wrap(@required).each do |attribute|
          raise ArgumentError, "Missing parameter #{attribute}" unless params[attribute]
        end

        @search_params = params.slice(*self.item.filterable)

        response = self.perform_find
        response = items_from(response, *Array.wrap(self.response_location))

        return response.first if amount == :first
        response
      end

      # Fields required to search
      def required(*symbols)
        @required = symbols
      end

      # Service name shorthand
      def service_name(symbol, *params)
        super(symbol)
        params.each do |param|
          case param
          when :p
          end
        end
      end

    end

    # Find it
    def perform_find
      get(self.selector, self.predicates)
    end

    def response_location
      :entries
    end

    # Create items from adwords response
    def items_from(response, *symbols)
      response.symbolize_all_keys!
      response.widdle(*symbols).map { |a| self.item(a) }
    end

    def new_from_symbol(symbol, params={})
      eval(symbol.to_s.camelize).new(params)
    end

    # Create sub class
    def new_from(params, *symbols)
      return nil unless kind = params.widdle(*symbols)
      return nil unless Toolkit.find_in(self.item.kinds, kind)
      new_from_symbol(kind, params)
    end

    # Fields to lookup and order
    def selector(name=nil)
      Toolkit.selector(self.item.selectable, name)
    end

    # Fields to filter by
    def predicates(params={})
      Toolkit.predicates(self.item.filterable, params.merge(@search_params))
    end

  end
end
