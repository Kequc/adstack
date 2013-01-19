module Adstack
  module Fieldset
    extend ActiveSupport::Concern

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
          result[key][:xsi_type] = Toolkit.adw(self.class.kind_shorthand || self.class.kind_sym)
        end
      end
      result.except_blank
    end

    module ClassMethods

      attr_writer :primary_key

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

      def embedded_params
        self.embedded.values.flatten
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

      # Define field
      def field(symbol, *params)
        self.fields << [symbol, params]
        self.initialize_field(symbol, *params)
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

    end

  end
end
