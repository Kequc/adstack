module Adstack
  module Config

    extend self

    # Initialize settings with a yml file and environment
    #
    def load!(path, environment=nil)
      @path = path
      @environment = environment || (Toolkit.env_production? ? :production : :sandbox)
      
      # Find config file
      if File.exists?(@path)
        @settings = YAML::load(ERB.new(File.read(@path)).result) rescue {}

        # Is it an adwords_api config-file?
        if @settings.present? and @settings[:authentication].present?
          n = {}
          n[@environment] = @settings
          @settings = n
        end
      else
        raise "Adstack yml file #{@path} does not exist."
      end

      @changed = true
      @settings.symbolize_all_keys!
    end

    def changed?
      result = !!@changed
      @changed = false
      result
    end

    # Display hash of all account settings
    #
    def settings(reload=false)
      return @settings if @settings and !reload
      raise "Path to adapi yml file not defined." unless @path
      @settings = self.load!(@path)
    end

    # Display actual account settings
    #
    def read
      @data || self.set
    end

    def get(symbol)
      self.read[:authentication][symbol.to_sym] rescue nil
    end

    def set(params={})
      custom_settings = self.settings[@environment]
      custom_settings[:authentication].merge!(params)

      @changed = true
      @data = custom_settings
    end

    def unset(*symbols)
      custom_settings = self.settings[@environment]
      symbols.each { |symbol| custom_settings[:authentication].delete(symbol) }

      @changed = true
      @data = custom_settings
    end

  end
end
