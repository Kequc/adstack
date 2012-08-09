module Adstack
  class KeywordEstimate < Helper

    ATTRIBUTES = [:keyword,
      :min_average_cpc, :max_average_cpc,
      :min_average_position, :max_average_position,
      :min_clicks_per_day, :max_clicks_per_day,
      :min_total_cost, :max_total_cost]
    attr_accessor *ATTRIBUTES

    def initialize(params={})
      params.symbolize_all_keys!
      params[:min] ||= {}
      params[:max] ||= {}
      %w{average_cpc average_position clicks_per_day total_cost}.each do |str|
        params["min_#{str}".to_sym] ||= params[:min][str.to_sym]
        params["max_#{str}".to_sym] ||= params[:max][str.to_sym]
      end
      super(ATTRIBUTES, params)
    end

    def keyword=(string)
      @keyword = string.to_s
    end

    def min_average_cpc=(min_average_cpc)
      @min_average_cpc = Money.new(min_average_cpc)
    end

    def max_average_cpc=(max_average_cpc)
      @max_average_cpc = Money.new(max_average_cpc)
    end

    def min_total_cost=(min_total_cost)
      @min_total_cost = Money.new(min_total_cost)
    end

    def max_total_cost=(max_total_cost)
      @max_total_cost = Money.new(max_total_cost)
    end

    def mean_average_cpc
      amount = ((self.min_average_cpc.micro_amount + self.max_average_cpc.micro_amount) / 2) rescue 0
      Money.new(micro_amount: amount)
    end

    def mean_average_position
      (self.min_average_position + self.max_average_position).to_f / 2
    end

    def mean_clicks_per_day
      (self.min_clicks_per_day + self.max_clicks_per_day).to_f / 2
    end

    def mean_total_cost
      amount = ((self.min_total_cost.micro_amount + self.max_total_cost.micro_amount) / 2) rescue 0
      Money.new(micro_amount: amount)
    end

    def mean_attributes
      {
        mean_average_cpc: self.mean_average_cpc.writeable_attributes,
        mean_average_position: self.mean_average_position,
        mean_clicks_per_day: self.mean_clicks_per_day,
        mean_total_cost: self.mean_total_cost.writeable_attributes
      }
    end

    def self.find(params={})
      TrafficEstimatorService.find(params)
    end

  end
end
