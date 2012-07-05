module Adstack
  class Service < Api

    attr_reader :search_params

    def initialize(params={})
      params.symbolize_all_keys!
      self.customer_id = params.delete(:customer_id)
      @search_params = params
    end

    class << self

      attr_reader :item_kinds, :item_kinds_locator

      def find(amount=:all, params={})
        params.symbolize_all_keys!

        Array.wrap(@required_search_params).each do |param|
          raise ArgumentError, "Missing parameter #{param}" unless params[param]
        end

        response = new(params).perform_find

        return response.first if amount == :first
        response
      end

      # Fields required for find
      def required(*symbols)
        @required_search_params = symbols
      end

      # Subclasses
      def kinds(*symbols)
        @item_kinds = symbols
      end

      def kinds_locator(*symbols)
        @item_kinds_locator = symbols
      end

      # Create sub class
      def new_from(params, *symbols)
        return nil unless kind = params.widdle(*symbols)
        return nil unless Toolkit.find_in(self.item_kinds, kind)
        Toolkit.classify(kind).new(params)
      end

      def item(params={})
        if self.item_kinds
          self.new_from(params, *self.item_kinds_locator)
        else
          self.child_class.new(params)
        end
      end

    end

    # Find it
    def perform_find
      response = get(self.selector, self.predicates)
      # Create items from adwords response
      response.symbolize_all_keys!
      response = response.widdle(*Array.wrap(self.class.item_location || :entries)) || []
      response.map! { |a| self.class.item(a) }
      response.each { |a| a.customer_id ||= self.customer_id }
      response
    end

    # Fields to lookup and order
    def selector(symbol=nil)
      Toolkit.selector(self.class.child_class.selectable, symbol)
    end

    # Fields to filter by
    def predicates(params={})
      Toolkit.predicates(self.class.child_class.filterable, params.merge(@search_params))
    end

  end
end
