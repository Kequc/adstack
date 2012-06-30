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
                min, max = *Array.wrap(value)
                max ||= min
                self.module_eval { validates_length_of name, minimum: min, maximum: max, allow_blank: true }
              when :w
                # Enumerable restriction
                self.module_eval { validates_inclusion_of name, :in => Array.wrap(value), allow_blank: true }
              when :m
                # Match restriction
                self.module_eval { validates_format_of name, with: value, allow_blank: true }
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

      def primary(symbol)
        @primary = symbol
      end

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

      def kinds(*symbols)
        @kinds = symbols
      end

    end

    def all_attributes
      # List of all item attributes
      (@embedded.values.flatten + @attributes).uniq
    end

    def persisted?
      @primary ? self.send(@primary).present? : false
    end

    def s
      self.persisted? ? 'SET' : 'ADD'
    end

    def response_location
      :value
    end

    def delete_operation
      self.attributes([@primary])
    end

    def perform_delete
      return false if @invincible
      self.mutate_explicit(self.service_name, 'REMOVE', self.delete_operation)
    end

    def delete
      return true unless self.persisted?
      instance_variable_set("@#{@primary}", nil) if self.perform_delete and @primary
    end

    def save_operation
      self.writeable_attributes
    end

    def perform_save
      self.mutate_explicit(self.service_name, self.s, self.save_operation)
    end

    def save
      return false unless self.valid?
      response = self.perform_save
      set_attributes_from(response, *Array.wrap(self.response_location))
    end

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

    def update_attributes(params)
      self.attributes = params
      self.save
    end

    def set_attributes_from(params *symbols)
      params = params.widdle(*symbols)
      return false unless params
      set_attributes(params)
      true
    end

    def attributes(list=nil)
      result = {}
      list ||= self.all_attributes
      Array.wrap(list).each do |attribute|
        result[attribute] = self.send(attribute)
      end
      result
    end

    def writeable_attributes
      result = self.attributes(@attributes.slice(*@writeable))
      @embedded.each_pair do |key, list|
        result.merge!(key => self.attributes(list.slice(*@writeable)))
      end
      result
    end

  end
end
