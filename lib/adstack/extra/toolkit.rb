module Adstack
  module Toolkit

    extend self

    def operation(operator, operand)
      operation = {
        :operator => operator,
        :operand => operand
      }
    end

    def predicates(attributes, params)
      result = Array.wrap(attributes).map do |param_name|
        if params[param_name]
          # Convert to array
          values = Array.wrap(params[param_name])
          { field: param_name.to_s.camelize, operator: 'IN', values: values }
        end
      end
      result.compact
    end

    def selector(fields, order_by=nil, start_index=nil, number_results=nil)
      result = { fields: fields.map { |f| f.to_s.camelize } }
      if order_by
        result.merge!(ordering: Array.wrap(order_by).map { |order| { field: order.to_s.camelize, sort_order: 'ASCENDING' } })
      end
      if start_index and number_results
        result.merge!(paging: { start_index: start_index, number_results: number_results })
      end
      result
    end

    # Convert number to micro units (unit * one million)
    #
    def microfy(num)
      (num.to_f * 1e6).to_i
    end

    def delete_name(name)
      "DELETED_#{name}_#{(Time.now.to_f*1000).to_i}"
    end

    def sym(string)
      string.to_s.underscore.to_sym
    end

    def adw(symbol)
      symbol.to_s.camelize
    end

    def servify(symbol)
      (Toolkit.adw(symbol)+"Service").to_sym
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
