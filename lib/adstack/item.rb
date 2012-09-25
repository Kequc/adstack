module Adstack
  class Item < Api
    include Adstack::Fieldset

    attr_writer :operator

    # Are we creating a new one
    def operator
      @operator || (self.persisted? ? 'SET' : 'ADD')
    end

    def initialize(params={})
      params.symbolize_all_keys!
      params = self.class.defaults.merge(params)
      self.class.lookup.each_pair do |key, value|
        params[key] = params.delete(value) if params.keys.include?(value)
      end
      self.class.datetimes.each_pair do |key, value|
        next unless params[key].present? and params[key].is_a?(String)
        case value
        when :time_zone
          params[key] = Toolkit.parse_time_zone(params[key])
        when :date
          params[key] = Toolkit.parse_date(params[key])
        end
      end
      set_attributes(params)
    end

    class << self
      attr_accessor :parent_sym, :kind_shorthand, :kind_predicate, :kind_location
      attr_writer :kind_sym

      def kind_sym; @kind_sym ||= self.item_sym; end

      def updateable?
        false
      end

      def deleteable?
        false
      end

      # Parent class object
      def parent_class
        Toolkit.classify(self.parent_sym)
      end

      # Mimic behaviour and fields of superclass
      def kind(symbol, *params)
        klass = self.superclass
        %w[fields primary_key delete_type update_type parent_sym kind_location].each do |param|
          self.instance_variable_set("@#{param}", klass.instance_variable_get("@#{param}"))
        end
        self.customer_id_free if klass.doesnt_need_customer_id
        self.service_api(klass.service_sym, r: klass.item_sym)
        klass.fields.each do |field|
          self.initialize_field(field[0], *field[1])
        end
        self.kind_sym = symbol
        if params.last.is_a?(Hash) and params.last[:r].present?
          self.kind_shorthand = params.last[:r]
        end
        self.service_class.add_item_kind(symbol, self.kind_shorthand)
        self.parent_class.initialize_child_methods(
          symbol,
          service_sym: klass.kind_sym,
          singular: params.include?(:s)
        )
      end

      # Specify how to format kind lookup
      def kind_lookup(kind_predicate, *params)
        self.kind_predicate = kind_predicate
        self.kind_location = params
      end

      def create(params={})
        result = new(params)
        result.save
        result
      end

      # Service name shorthand
      def service_api(symbol, *params)
        super(symbol, *params)
        params.each do |param|

          case param
          when Hash
            param.each_pair do |key, value|

              case key
              when :p
                # Unusual primary key
                self.primary_key = value
              end

            end
          end

        end
      end

      def item_kinds
        self.service_class.item_kinds
      end

      # Support batch operations
      def can_batch
        self.parent_class.initialize_batch_methods(self.kind_sym)
      end

      def initialize_batch_methods(symbol)
        kind_class = Toolkit.classify(symbol)
        shorthand = kind_class.kind_shorthand
        method = (shorthand.blank? ? symbol : shorthand).to_s.pluralize

        # Build method
        define_method("build_#{method}") do |operations=[]|
          Array.wrap(operations).map do |a|
            unless a.is_a?(kind_class)
              a = kind_class.new(a)
              a.set_attributes(self.child_params)
            end
            a
          end
        end

        # Create method
        define_method("create_#{method}") do |operations=[]|
          # Convert operations into objects
          operations = self.send("build_#{method}", operations)
          # Remove invalid operations
          operations.keep_if {|a| a.valid_for_adwords?}
          # Get operations for each object
          operations.map! {|a| Toolkit.operation(a.operator, a.save_operation)}
          # Perform batch operation
          response = kind_class.new(self.child_params).mutate(operations) unless operations.empty?
          if response and response[:value]
            true
          else
            false
          end
        end

        # Delete method
        unless kind_class.deleteable?
          define_method("delete_#{method}") do
            # Get operations for each object
            operations = self.send(method).map {|a| Toolkit.operation('REMOVE', a.delete_operation)}
            # Perform batch operation
            kind_class.new(self.child_params).mutate(operations) unless operations.empty?
            true
          end
        end
      end

      # Symbol representation of parent class
      def parent(symbol)
        self.parent_sym = symbol
        self.parent_class.initialize_child_methods(self.kind_sym)
      end

      def initialize_child_methods(symbol, options={})
        options[:service_sym] ||= symbol
        service_class = self.service_class(options[:service_sym])
        item_class = self.item_class(symbol)
        options[:kind_shorthand] = item_class.kind_shorthand
        method = (options[:kind_shorthand] || symbol).to_s

        # Find method
        define_method(!!options[:singular] ? method : method.pluralize) do |params={}|
          params.merge!(self.child_params)
          if options[:kind_shorthand]
            params.merge!(kind_shorthand: options[:kind_shorthand])
          end
          if options[:service_sym] != symbol
            params.merge!(kind: symbol)
          end
          service_class.find((options[:singular] ? :first : :all), params)
        end

        # Build method
        define_method("build_#{method}") do |params={}|
          item_class.new(params.merge(self.child_params))
        end

        # Create method
        define_method("create_#{method}") do |params={}|
          result = self.send("build_#{method}", params)
          result.save
          result
        end
      end

      def service_class(symbol=nil)
        symbol ||= self.item_sym
        Toolkit.classify("#{symbol}_service")
      end

      def item_class(symbol=nil)
        if symbol ||= self.kind_sym
          Toolkit.classify(symbol)
        else
          super
        end
      end

      def find(amount=:all, params={})
        self.service_class.find(amount, params)
      end

    end

    def customer_object
      @customer_object ||= self.customer_id.present? ? Customer.find(:first, customer_id: self.customer_id) : nil
    end

    def date_time_zone
      self.customer_object ? self.customer_object.date_time_zone : nil
    end

    def valid_for_adwords?
      if self.operator == 'REMOVE'
        return false unless self.class.deleteable?
        self.get_primary.present?
      else
        self.valid?
      end
    end

    # Unlink object from adwords instance
    def deprovision(symbols=nil)
      symbols = Array.wrap(symbols) | [self.class.primary_key, :status]
      params = {}
      symbols.each { |s| params.merge!(s => self.class.defaults[s]) }
      set_attributes(params)
    end

    # Attributes to use for save operation
    def save_operation
      self.writeable_attributes
    end

    # Save it
    def perform_save
      if self.persisted?
        # Cannot update -> delete and replace instead
        return false unless self.respond_to?(:delete) and self.delete
      end
      self.mutate_explicit(self.operator, self.save_operation)
    end

    def save
      return false unless self.valid?
      return false unless response = self.perform_save
      if response = response.widdle(*Array.wrap([:value, 0]))
        set_attributes(response)
        self.persisted?
      else
        false
      end
    end

  end
end
