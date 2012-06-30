module AdStack
  class Item < Api

    @attributes = []
    @writeable  = []
    @filterable = []
    @selectable = []
    @embedded   = {}
    @invincible = false
    attr_reader :filterable, :selectable, :kinds

    def initialize(params={})
      set_attributes(params)
    end

    class << self

      # Define field parameters
      def field(name, *symbols)
        if symbols.include?(:ro)
          # Read only
          self.module_eval { attr_reader name }
        else
          self.module_eval { attr_accessor name }
          @writeable << name
        end
        symbols.each do |symbol|
          case symbol
          when :f
            # Filterable
            @filterable << name
          when :r
            # Required
            self.module_eval { validates_presence_of name }
          when :s
            # Selectable
            @selectable << name
          when Hash
            symbol.each_pair do |key, value|
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
                self.module_eval { validates_length_of name, arguments }
              when :w
                # Enumerable restriction
                self.module_eval { validates_inclusion_of name, :in => Array.wrap(value), allow_blank: true }
              when :m
                # Match restriction
                self.module_eval { validates_format_of name, with: value, allow_blank: true }
              when :r
                # Range restriction
                if value.is_a?(Array)
                  min, max = *value
                  max ||= min
                  arguments = { greater_than_or_equal_to: min, less_than_or_equal_to: max }
                else
                  arguments = { equal_to: value }
                end
                self.module_eval { validates_numericality_of name, arguments }
              when :e
                # Embedded field
                @embedded[value] << name
              end
            end
          end
        end
        @attributes << name unless @embedded.keys.include?(name)
      end

      def create(params={})
        result = new(params)
        result.save
        result
      end

      # Primary key
      def primary(symbol)
        @primary = symbol
      end

      # Service name shorthand
      def service_name(symbol, *params)
        super(symbol)
        params.each do |param|
          case param
          when :p
            # No option to delete
            @invincible = true
          end
        end
      end

      # Subclasses
      def kinds(*symbols)
        @kinds = symbols
      end

    end

    # List of all item attributes
    def all_attributes
      (@embedded.values.flatten + @attributes).uniq
    end

    # Is existing record?
    def persisted?
      @primary ? self.send(@primary) : false
    end

    # Create or modify
    def s
      self.persisted? ? 'SET' : 'ADD'
    end

    def response_location
      :value
    end

    # Attributes to use for delete operation
    def delete_operation
      self.attributes([@primary])
    end

    # Delete it
    def perform_delete
      return false if @invincible
      self.mutate_explicit(self.service_name, 'REMOVE', self.delete_operation)
    end

    def delete
      return true unless self.persisted?
      instance_variable_set("@#{@primary}", nil) if self.perform_delete and @primary
    end

    # Attributes to use for save operation
    def save_operation
      self.writeable_attributes
    end

    # Save it
    def perform_save
      self.mutate_explicit(self.service_name, self.s, self.save_operation)
    end

    def save
      return false unless self.valid?
      response = self.perform_save
      set_attributes_from(response, *Array.wrap(self.response_location))
    end

    # Update class fields
    def set_attributes(params, list=nil)
      params.symbolize_all_keys!
      list ||= self.all_attributes
      Array.wrap(list).each do |attribute|
        value = params[attribute]
        instance_variable_set("@#{attribute}", value) if value
      end
    end

    def attributes=(params)
      self.set_attributes(params, @writeable)
    end

    # Update and save
    def update_attributes(params)
      self.attributes = params
      self.save
    end

    # Set attributes using adwords response
    def set_attributes_from(params *symbols)
      params = params.widdle(*symbols)
      return false unless params
      self.set_attributes(params)
      true
    end

    # Return attributes
    def attributes(list=nil)
      result = {}
      list ||= self.all_attributes
      Array.wrap(list).each do |attribute|
        result[attribute] = self.send(attribute)
      end
      result
    end

    # Return attributes for adwords
    def writeable_attributes
      result = self.attributes(@attributes.slice(*@writeable))
      @embedded.each_pair do |key, list|
        result.merge!(key => self.attributes(list.slice(*@writeable)))
      end
      result
    end

  end
end
