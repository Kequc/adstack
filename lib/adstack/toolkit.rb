module Adstack
  module Toolkit

    extend self

    def operation(operator, operand)
      operation = {
        :operator => operator,
        :operand => operand
      }
    end

    def predicates(symbols, params)
      result = Array.wrap(symbols).map do |symbol|
        if params[symbol]
          # Convert to array
          values = Array.wrap(params[symbol])
          { field: Toolkit.adw(symbol), operator: 'IN', values: values }
        end
      end
      result.compact
    end

    def selector(symbols, order_by=nil, start_index=nil, number_results=nil)
      result = { fields: symbols.map { |f| Toolkit.adw(f) } }
      if order_by
        result.merge!(ordering: Array.wrap(order_by).map { |order| { field: Toolkit.adw(order), sort_order: 'ASCENDING' } })
      end
      if start_index and number_results
        result.merge!(paging: { start_index: start_index, number_results: number_results })
      end
      result
    end

    # Convert number to micro units (unit * one million)
    #
    def microfy(num)
      return nil unless num
      (num.to_f * 1e6).to_i
    end

    def largify(num)
      return nil unless num
      (num.to_f / 1e6)
    end

    def delete_name(str)
      "DELETED_#{str}_#{(Time.now.to_f*1000).to_i}"
    end

    def sym(string)
      string.to_s.underscore.to_sym
    end

    def adw(symbol)
      symbol.to_s.camelize
    end

    def enu(symbol)
      symbol.to_s.upcase
    end

    def classify(symbol)
      eval("Adstack::"+Toolkit.adw(symbol))
    end

    def servify(symbol)
      (Toolkit.adw(symbol)+"Service").to_sym
    end

    def string_timezone(time, time_zone="America/Los_Angeles")
      time.in_time_zone(time_zone).strftime("%Y%m%d %H%M%S #{time_zone}") rescue nil
    end

    def string_date(date)
      date.strftime('%Y%m%d') rescue nil
    end

    def parse_timezone(string)
      string = string.split(" ")
      tz = string.pop
      Time.parse(string.join(" ")).in_time_zone(tz).utc
    end

    def parse_date(string)
      Date.parse(string)
    end

    def find_in(symbols, query)
      Array.wrap(symbols).include?(Toolkit.sym(query))
    end

    def env
      if defined?(Rails)
        env = Rails.env.to_s
      elsif defined?(Sinatra)
        env = Sinatra::Base.environment.to_s
      else
        env = ENV["RACK_ENV"] || 'development'
      end
      env.to_sym
    end

    def env_production?
      env == :production
    end

  end
end
