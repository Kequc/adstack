module Adstack
  class Service < Api

    attr_accessor :attributes, :kind

    def initialize(params={})
      params.symbolize_all_keys!
      self.customer_id = params.delete(:customer_id)
      self.kind = params.delete(:kind)
      self.attributes = params
    end

    class << self

      def item_kinds; @item_kinds ||= []; end

      def find(amount=:all, params={})
        srv = new(params)

        Array.wrap(@required_search_params).each do |param|
          raise ArgumentError, "Missing parameter #{param}" unless srv.attributes[param]
        end

        response = srv.perform_find

        return response.first if amount == :first
        return response.sample if amount == :sample
        response
      end

      # Fields required for find
      def required(*symbols)
        @required_search_params = symbols
      end

      # Create sub class
      def new_item_from(params)
        return nil unless kind = params.widdle(*self.item_class.kind_location)
        return nil unless Toolkit.find_in(self.item_kinds, kind)
        Toolkit.classify(kind).new(params)
      end

      def item(params={})
        if !self.item_kinds.empty?
          self.new_item_from(params)
        else
          super(params)
        end
      end

    end

    # Class used to perform lookups
    def lookup_class
      if self.kind
        Toolkit.classify(self.kind)
      else
        self.class.item_class
      end
    end

    # Find it
    def perform_get
      response = get(self.selector, self.predicates)
      response.symbolize_all_keys!
      response = response.widdle(*Array.wrap(self.class.item_location || :entries)) || []
    end

    # Turn response into useful items
    def perform_find
      response = self.perform_get.uniq
      response.map! { |a| self.class.item(a) }
      response.each { |a| a.customer_id ||= self.customer_id }
      response
    end

    # Fields to lookup and order
    def selector(symbol=nil)
      result = Toolkit.selector(self.lookup_class.selectable_lookup, symbol)
      puts "Selector:"
      puts result.inspect
      result
    end

    # Fields to filter by
    def predicates(params={})
      filterable = self.lookup_class.filterable
      params.merge!(self.attributes)
      if self.kind
        key = self.class.item_class.kind_predicate
        params.merge!(key => Toolkit.enu(self.kind))
        filterable |= [key]
      end
      result = Toolkit.predicates(filterable, params)
      puts "Predicates:"
      puts result.inspect
      result
    end

  end
end
