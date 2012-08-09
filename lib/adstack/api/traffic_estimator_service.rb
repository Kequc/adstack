module Adstack
  class TrafficEstimatorService < Api

    ATTRIBUTES = [:keywords, :campaign_id, :max_cpc, :locations, :languages, :network_setting, :daily_budget]
    attr_accessor *ATTRIBUTES

    service_api :traffic_estimator, r: :keyword_estimate

    customer_id_free

    def initialize(params={})
      params.symbolize_all_keys!
      params[:locations] ||= params[:location]
      params[:languages] ||= params[:language]
      ATTRIBUTES.each do |symbol|
        self.send("#{symbol}=", params[symbol]) if params[symbol].present?
      end
    end

    def network_setting=(params={})
      @max_cpc = NetworkSetting.new(params)
    end

    def daily_budget=(params={})
      @max_cpc = Money.new(params)
    end

    def max_cpc=(params={})
      @max_cpc = Money.new(params)
    end

    def keywords=(keywords=[])
      @keywords = Array.wrap(keywords).map { |k| Keyword.new(k) }
    end

    def locations=(locations=[])
      @locations = Array.wrap(locations)
    end

    def languages=(languages=[])
      @languages = Array.wrap(languages)
    end

    def self.find(params={})
      # Return list
      srv = new(params)
      estimates = srv.perform_find || []

      i = 0
      estimates.map! do |e|
        i += 1
        e[:keyword] = srv.keywords[i]
        self.item(e)
      end

      estimates
    end

    def keyword_estimate_requests
      self.keywords.map do |k|
        result = {xsi_type: 'Keyword', text: k.text, match_type: k.match_type}
        result[:is_negative] = true if k.is_negative
        {keyword: result}
      end
    end

    def ad_group_estimate_requests
      result = {
        keyword_estimate_requests: self.keyword_estimate_requests,
        max_cpc: self.max_cpc.writeable_attributes
      }
      Array.wrap(result)
    end

    def criteria
      result = []
      Array.wrap(self.locations).each do |location|
        result << {xsi_type: 'Location', id: location}
      end
      Array.wrap(self.languages).each do |language|
        result << {xsi_type: 'Language', id: language}
      end
      result
    end

    def campaign_estimate_requests
      result = {
        ad_group_estimate_requests: self.ad_group_estimate_requests
      }
      result[:criteria] = self.criteria unless self.criteria.empty?
      result[:campaign_id] = self.campaign_id if self.campaign_id.present?
      result[:network_setting] = self.network_setting.writeable_attributes if self.network_setting
      result[:daily_budget] = self.daily_budget.writeable_attributes if self.daily_budget
      Array.wrap(result)
    end

    def operation
      {
        campaign_estimate_requests: self.campaign_estimate_requests
      }
    end

    # Find it
    def perform_find
      [:max_cpc].each do |param|
        raise ArgumentError, "Missing parameter #{param}" unless self.send(param).present?
      end

      response = self.get(self.operation)
      response = response.widdle(:campaign_estimates, 0, :ad_group_estimates, 0, :keyword_estimates)
      response
    end

  end
end
