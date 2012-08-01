module Adstack
  class Item < Api

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

      attr_reader :delete_type, :update_type, :parent_sym, :kind_sym, :kind_predicate, :kind_location

      def normal;       @normal       ||= [];   end
      def writeable;    @writeable    ||= [];   end
      def filterable;   @filterable   ||= [];   end
      def selectable;   @selectable   ||= [];   end
      def embedded;     @embedded     ||= {};   end
      def required;     @required     ||= [];   end
      def fields;       @fields       ||= [];   end
      def primary_key;  @primary_key  ||= :id;  end
      def defaults;     @defaults     ||= {};   end
      def permanent;    @permanent    ||= [];   end
      def lookup;       @lookup       ||= {};   end
      def datetimes;    @datetimes    ||= {};   end

      # List of fields for selector
      def selectable_lookup
        self.selectable.map do |symbol|
          self.lookup.keys.include?(symbol) ? self.lookup[symbol] : symbol
        end
      end

      # Define field
      def field(symbol, *params)
        self.fields << [symbol, params]
        self.initialize_field(symbol, *params)
      end

      # Parent class object
      def parent_class
        Toolkit.classify(self.parent_sym)
      end

      # Add field
      def initialize_field(symbol, *params)
        if params.include?(:ro)
          # Read only
          self.module_eval { attr_reader symbol }
        else
          self.module_eval { attr_accessor symbol }
          self.writeable << symbol
        end

        params.each do |param|
          case param
          when :f
            # Filterable
            self.filterable << symbol
          when :r
            # Required
            self.module_eval { validates_presence_of symbol }
            self.required << symbol
          when :roc
            # Required on create
            self.module_eval { validates_presence_of symbol, unless: :persisted? }
          when :rou
            # Required on update
            self.module_eval { validates_presence_of symbol, if: :persisted? }
          when :s
            # Selectable
            self.selectable << symbol
          when :p
            # Permanent after create
            self.permanent << symbol
            define_method("#{symbol}=") do |value|
              if self.persisted?
                raise NoMethodError
              else
                instance_variable_set("@#{symbol}", value)
              end
            end
          when Hash
            param.each_pair do |key, value|

              case key
              when :l
                # Length restriction
                if value.is_a?(Array)
                  min, max = *value
                  max ||= min
                  arguments = { minimum: min, maximum: max, allow_blank: true }
                else
                  arguments = { minimum: value, allow_blank: true }
                end
                self.module_eval { validates_length_of symbol, arguments }
              when :w
                # Enumerable restriction
                self.module_eval { validates_inclusion_of symbol, :in => Array.wrap(value), allow_blank: true }
              when :m
                # Match restriction
                self.module_eval { validates_format_of symbol, with: value, allow_blank: true }
              when :r
                # Range restriction
                if value.is_a?(Array)
                  min, max = *value
                  max ||= min
                  arguments = { greater_than_or_equal_to: min, less_than_or_equal_to: max }
                else
                  arguments = { equal_to: value }
                end
                self.module_eval { validates_numericality_of symbol, arguments }
              when :e
                # Embedded field
                self.embedded[value] ||= []
                self.embedded[value] << symbol
              when :d
                # Default value
                self.defaults.merge!(symbol => value)
              when :h
                # Corresponds to helper
                define_method("#{symbol}=") do |params={}|
                  params = value.new(params) rescue params
                  instance_variable_set("@#{symbol}", params)
                end
              when :lu
                # Name to lookup by is different
                self.lookup.merge!(symbol => value)
              when :t
                # Format the time/date
                self.datetimes.merge!(symbol => value)
              end

            end
          end
        end

        self.normal << symbol unless self.embedded_params.include?(symbol)
      end

      # Mimic behaviour and fields of superclass
      def kind(symbol, *params)
        klass = self.superclass
        %w[fields primary_key delete_type update_type parent_sym kind_location].each do |param|
          self.instance_variable_set("@#{param}", klass.instance_variable_get("@#{param}"))
        end
        self.customer_id_free if klass.doesnt_need_customer_id
        self.service_api(klass.service_sym, r: klass.item_sym, l: klass.item_location)
        klass.fields.each do |field|
          self.initialize_field(field[0], *field[1])
        end
        @kind_sym = symbol
        self.service_class.item_kinds << symbol
        self.parent_class.initialize_child_methods(symbol, klass.item_sym, params.include?(:s))
      end

      # Specify how to format kind lookup
      def kind_lookup(kind_predicate, *params)
        @kind_predicate = kind_predicate
        @kind_location = params
      end

      def embedded_params
        self.embedded.values.flatten
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
                @primary_key = value
              end

            end
          end

        end
      end

      def cannot_delete(*params)
        @delete_type = :disabled
        params.each do |param|
          case param
          when :set_status
            @delete_type = :set_status
          end
        end
      end

      def cannot_update
        @update_type = :disabled
      end

      def item_kinds
        Array.wrap(self.service_class.item_kinds)
      end

      def service_class(symbol=nil)
        symbol ||= self.item_sym
        Toolkit.classify("#{symbol}_service")
      end

      # Support batch operations
      def can_batch
        self.parent_class.initialize_batch_methods(self.kind_sym)
      end

      def initialize_batch_methods(symbol)
        kind_class = Toolkit.classify(symbol)
        method = symbol.to_s.pluralize

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
          kind_class.new(self.child_params).mutate(operations)
        end
      end

      # Symbol representation of parent class
      def parent(symbol)
        @parent_sym = symbol
        self.parent_class.initialize_child_methods(self.item_sym)
      end

      def initialize_child_methods(symbol, service_sym=nil, singular=false)
        find_method = symbol.to_s
        find_method = find_method.pluralize unless singular
        service_sym ||= symbol
        service_class = self.service_class(service_sym)

        # # Get each kind individually and merge them together
        # all_method = service_sym.to_s.pluralize
        # unless self.method_defined?(all_method)
        #   define_method(all_method) do |params={}|
        #     params.merge!(self.child_params)
        #     response = service_class.new(params).perform_get
        #     to_lookup = []
        #     response.each do |item|
        #       to_lookup << Toolkit.sym(item.widdle(*self.class.kind_location))
        #     end
        #     result = []
        #     to_lookup.uniq.each do |kind|
        #       params[:kind] = kind
        #       result += service_class.find(:all, params)
        #     end
        #     result
        #   end
        # end

        # Find method
        define_method(find_method) do |params={}|
          params.merge!(self.child_params)
          params.merge!(kind: symbol) if service_sym != symbol
          service_class.find((singular ? :first : :all), params)
        end

        # Build method
        define_method("build_#{symbol}") do |params={}|
          Toolkit.classify(symbol).new(params.merge(self.child_params))
        end

        # Create method
        define_method("create_#{symbol}") do |params={}|
          result = self.send("build_#{symbol}", params)
          result.save
          result
        end
      end

      def item_class
        if self.kind_sym
          Toolkit.classify(self.kind_sym)
        else
          super
        end
      end

      # Returns navigation to specified field
      def field_location(symbol)
        result = []
        self.item_class.embedded.each_pair do |key, value|
          next unless value.include?(symbol)
          result << key
          break
        end
        result << symbol
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
        self.get_primary.present?
      else
        self.valid?
      end
    end

    # Get fresh information from adwords
    def reload
      return false unless self.persisted?
      symbols = [:customer_id, self.class.primary_key]
      parent_id_sym = "#{self.class.parent_sym}_id".to_sym
      symbols << parent_id_sym if self.all_attributes.include?(parent_id_sym)
      if result = self.class.find(:first, self.attributes(symbols))
        self.set_attributes(result.attributes)
        true
      else
        false
      end
    end

    # List params for looking up and creating child instances
    def child_params(params={})
      params.merge(customer_id: self.customer_id)
    end

    # List of all item attributes
    def all_attributes
      (self.class.embedded_params + self.class.normal).uniq
    end

    def get_primary
      self.send(self.class.primary_key)
    end

    # Is existing record?
    def persisted?
      !!self.get_primary
    end

    # Attributes to use for delete operation
    def delete_operation
      self.writeable_attributes(self.class.required | [self.class.primary_key])
    end

    def can_delete?
      self.class.delete_type != :disabled
    end

    def set_status_delete?
      self.class.delete_type == :set_status
    end

    def can_update?
      self.class.update_type != :disabled
    end

    # Delete it
    def perform_delete
      return false unless self.can_delete?
      if self.set_status_delete?
        params = { status: 'DELETED' }
        params.merge!(name: Toolkit.delete_name(self.name)) if self.respond_to?(:name)
        self.update_attributes(params)
      else
        self.mutate_explicit('REMOVE', self.delete_operation)
        self.deprovision
      end
      true
    end

    # Unlink object from adwords instance
    def deprovision(symbols=nil)
      symbols = Array.wrap(symbols) | [self.class.primary_key, :status]
      params = {}
      symbols.each { |s| params.merge!(s => self.class.defaults[s]) }
      set_attributes(params)
    end

    def delete
      return true unless self.persisted?
      self.perform_delete
    end

    # Attributes to use for save operation
    def save_operation
      self.writeable_attributes
    end

    # Save it
    def perform_save
      if self.persisted? and !self.can_update?
        # Cannot update -> delete and replace instead
        return false unless self.delete
      end
      self.mutate_explicit(self.operator, self.save_operation)
    end

    def save
      return false unless self.valid?
      return false unless response = self.perform_save
      if response = response.widdle(*Array.wrap(self.class.item_location || [:value, 0]))
        set_attributes(response)
        self.persisted?
      else
        false
      end
    end

    # Update class fields
    def set_attributes(params, list=nil)
      params.symbolize_all_keys!
      # Destruct adwords formatting
      self.class.embedded.keys.each do |key|
        params.merge!(params.delete(key) || {})
      end
      list ||= (self.all_attributes | [:customer_id, :operator])
      params.slice(*list).each_pair do |key, value|
        begin
          self.send("#{key}=", value)
        rescue
          instance_variable_set("@#{key}", value)
        end
      end
    end

    def attributes=(params)
      self.set_attributes(params, self.class.writeable)
    end

    # Update and save
    def update_attributes(params)
      self.attributes = params
      self.save
    end
    alias_method :set, :update_attributes

    # Return attributes
    def attributes(symbols=nil, for_output=false)
      result = {}
      symbols ||= self.all_attributes
      method_name = for_output ? :writeable_attributes : :attributes
      Array.wrap(symbols).each do |symbol|
        value = self.send(symbol)
        if !value.is_a?(String) and value.respond_to?(method_name)
          value = value.send(method_name)
        end
        if (value.is_a?(Date) or value.is_a?(Time)) and for_output and convert = self.class.datetimes[symbol]
          case convert
          when :time_zone
            value = Toolkit.string_time_zone(value, self.date_time_zone)
          when :date
            value = Toolkit.string_date(value)
          end
        end
        result[symbol] = value
      end
      result
    end

    # Helper method for writeable_attributes
    def attributes_for_writeable_attributes(symbols)
      symbols = symbols & (self.class.writeable | [self.class.primary_key])
      symbols -= self.class.permanent if self.persisted?
      self.attributes(symbols, true)
    end

    # Return attributes for adwords
    def writeable_attributes(symbols=nil)
      symbols ||= self.all_attributes
      result = self.attributes_for_writeable_attributes(self.class.normal & symbols)
      self.class.embedded.each_pair do |key, value|
        result.merge!(key => self.attributes_for_writeable_attributes(value & symbols))
        if self.class.kind_location and key == self.class.kind_location.first
          result[key][:xsi_type] = Toolkit.adw(self.class.kind_sym)
        end
      end
      result.except_blank
    end

  end
end
