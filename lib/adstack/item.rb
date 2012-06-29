module AdStack
  class Item < Api

    @attributes = []
    @less       = []
    @writeable  = []
    @filterable = []
    @selectable = []
    attr_reader :attributes, :less, :filterable, :selectable

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
              end
            end
          end
        end
        if symbols.include?(:less)
          @less << name
        else
          # List of all item attributes
          @attributes << name
        end
      end

      def primary(name)
        @primary = name
      end

    end

    def persisted?
      @primary ? self.send(@primary).present? : false
    end

    def o
      self.persisted? ? 'SET' : 'ADD'
    end

    def save_operation
      nil
    end

    def delete_operation
      nil
    end

    def response_location
      :value
    end

    def save
      return false unless self.valid?
      response = self.save_operation
      set_attributes_from(response, *Array.wrap(self.response_location))
    end

    def update_attributes(params)
      self.attributes = params
      self.save
    end

    def self.create(params={})
      result = new(params)
      result.save
      result
    end

    def delete
      return true unless self.persisted?
      self.delete_operation
      instance_variable_set("@#{@primary}", nil) if @primary
    end

    def set_attributes(params, limit=nil)
      params.symbolize_all_keys!

      limit ||= (@attributes | @less)
      limit.each do |attribute|
        value = params[attribute]
        instance_variable_set("@#{attribute}", value) if value
      end
    end

    def set_attributes_from(response *symbols)
      response = response.widdle(*symbols)

      return false unless response
      set_attributes(response)
      true
    end

    def attributes=(params)
      self.set_attributes(params, @writeable)
    end

    def attributes(less=false)
      list = less ? @less : @attributes
      result = {}
      list.each do |attribute|
        result[attribute] = self.send(attribute)
      end
      result
    end

    def writeable_attributes(less=false)
      self.attributes(less).slice(*@writeable)
    end

  end
end
