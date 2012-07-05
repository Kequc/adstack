module Adstack
  class Item < Api

    def initialize(params={})
      self.customer_id = params.delete(:customer_id)
      set_attributes(params)
    end

    class << self

      attr_reader :delete_type, :parent_sym

      def normal;       @normal       ||= [];   end
      def writeable;    @writeable    ||= [];   end
      def filterable;   @filterable   ||= [];   end
      def selectable;   @selectable   ||= [];   end
      def embedded;     @embedded     ||= {};   end
      def fields;       @fields       ||= [];   end
      def primary;      @primary      ||= :id;  end
      def children_sym; @children_sym ||= [];   end

      # Define field parameters
      def field(symbol, *params)
        self.fields << [symbol, params]
        self.initialize_field(symbol, *params)
      end

      # Mimic behaviour and fields of superclass
      def kind(symbol)
        klass = Toolkit.classify(symbol)
        %w[fields primary children_sym delete_type parent_sym].each do |param|
          self.instance_variable_set("@#{param}", klass.instance_variable_get("@#{param}"))
        end
        self.customer_id_free if klass.doesnt_need_customer_id
        self.service_api(klass.service_sym, r: klass.class_sym, l: klass.item_location)
        self.fields.each do |field|
          self.initialize_field(field[0], *field[1])
        end
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
          when :s
            # Selectable
            self.selectable << symbol
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
              end

            end
          end
        end

        self.normal << symbol unless self.embedded.keys.include?(symbol)
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
                @primary = value
              end

            end
          end

        end
      end

      def cannot_delete(*params)
        @delete_type = :invincible
        params.each do |param|
          case param
          when :set_status
            @delete_type = :set_status
          end
        end
      end

      def item_kinds
        Array.wrap(self.service_class.item_kinds)
      end

      def service_class
        Toolkit.classify("#{self.class_sym}_service")
      end

      # Symbol representation of parent class
      def parent(symbol)
        @parent_sym = symbol
      end

      # Symbol representation of child classes
      def children(*symbols)
        @children_sym = symbols

        symbols.each do |symbol|
          method_names = {
            find: symbol.to_s.pluralize.to_sym,
            build: "build_#{symbol}".to_sym,
            create: "create_#{symbol}".to_sym
          }

          # Find method
          define_method(method_names[:find]) do |params={}|
            Toolkit.classify("#{symbol}_service").find(:all, params.merge(self.child_attributes))
          end

          # Initialize method
          define_method(method_names[:build]) do |params={}|
            Toolkit.classify(symbol).new(params.merge(self.child_attributes))
          end

          # Create method
          define_method(method_names[:create]) do |params={}|
            result = self.send(method_names[:build], params)
            result.save
            result
          end
        end
      end

      def find(amount=:all, params={})
        self.service_class.find(amount, params)
      end

    end

    # Get fresh information from adwords
    def reload
      return false unless self.persisted?
      params = {self.class.primary => self.get_primary}
      params.merge!(customer_id: self.customer_id)
      if result = self.class.find(:first, params)
        self.set_attributes(result.attributes)
        true
      else
        false
      end
    end

    # List attributes for looking up and creating child instances
    def child_attributes(params={})
      params.merge(customer_id: self.customer_id)
    end

    # List of all item attributes
    def all_attributes
      (self.class.embedded.values.flatten + self.class.normal).uniq
    end

    def get_primary
      self.send(self.class.primary)
    end

    # Is existing record?
    def persisted?
      !!self.get_primary
    end

    # Attributes to use for delete operation
    def delete_operation
      self.attributes([self.class.primary])
    end

    def can_delete?
      self.class.delete_type != :invincible
    end

    def set_status_delete?
      self.class.delete_type == :set_status
    end

    # Delete it
    def perform_delete
      return false unless self.can_delete?
      if self.set_status_delete?
        self.update_attributes(name: Toolkit.delete_name(self.name), status: 'DELETED')
      else
        self.mutate_explicit('REMOVE', self.delete_operation)
      end
    end

    def delete
      return true unless self.persisted?
      instance_variable_set("@#{self.class.primary}", nil) if self.perform_delete
    end

    # Are we creating a new one
    def save_operator
      self.persisted? ? 'SET' : 'ADD'
    end

    # Attributes to use for save operation
    def save_operation
      self.writeable_attributes
    end

    # Save it
    def perform_save
      self.mutate_explicit(self.save_operator, self.save_operation)
    end

    def save
      return false unless self.valid?
      response = self.perform_save
      set_attributes_from(response, *Array.wrap(self.class.item_location || :value))
    end

    # Update class fields
    def set_attributes(params, list=nil)
      params.symbolize_all_keys!
      list ||= self.all_attributes
      Array.wrap(list).each do |param|
        value = params[param]
        instance_variable_set("@#{param}", value) if value
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

    # Set attributes using adwords response
    def set_attributes_from(params, *symbols)
      params = params.widdle(*symbols)
      return false unless params
      self.class.embedded.each_pair do |key, list|
        params.merge!(params.delete(key))
      end
      self.set_attributes(params)
      true
    end

    # Return attributes
    def attributes(list=nil)
      result = {}
      list ||= self.all_attributes
      Array.wrap(list).each do |param|
        result[param] = self.send(param)
      end
      result
    end

    # Return attributes for adwords
    def writeable_attributes
      result = self.attributes(self.class.normal & self.class.writeable)
      self.class.embedded.each_pair do |key, list|
        result.merge!(key => self.attributes(list & self.class.writeable))
      end
      result
    end

  end
end
