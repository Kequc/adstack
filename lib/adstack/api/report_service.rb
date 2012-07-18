module Adstack
  class ReportService < Api

    ATTRIBUTES = [:report_name, :report_type, :download_format, :date_range_type, :date_range, :include_zero_impressions]
    attr_accessor *ATTRIBUTES

    def external_api
      self.adwords.report_utils(Adstack::API_VERSION)
    end

    def all_attributes
      ATTRIBUTES | [:customer_id]
    end

    def initialize(params={})
      params.symbolize_all_keys!

      self.all_attributes.each do |symbol|
        self.send("#{symbol}=", params[symbol]) if params[symbol].present?
      end

      self.download_format ||= :xml
      self.report_name ||= "A Report"
      self.report_type ||= :ad_performance_report
      self.date_range_type ||= :last_7_days
      self.include_zero_impressions ||= false
    end

    def self.find(params={})
      new(params.symbolize_all_keys).perform_find
    end

    def date_range=(dates)
      return unless dates.is_a?(Hash)
      # Format dates to strings
      dates.each_pair { |k,v| dates[k] = Toolkit.string_date(v) } rescue nil

      if dates[:min].blank? or dates[:max].blank?
        self.date_range_type = :last_7_days
      else
        self.date_range_type = :custom_date
      end

      @date_range = dates
    end

    def download_format=(symbol)
      symbols = [:csvforexcel, :csv, :tsv, :xml, :gzipped_csv, :gzipped_xml]
      if symbols.include?(symbol)
        @download_format = symbol
      else
        puts "Invalid download_format: #{symbol}"
      end
    end

    def report_type=(symbol)
      symbols = [:keywords_performance_report, :ad_performance_report, :url_performance_report,
        :adgroup_performance_report, :campaign_performance_report, :account_performance_report, :geo_performance_report,
        :search_query_performance_report, :managed_placements_performance_report, :automatic_placements_performance_report,
        :campaign_negative_keywords_performance_report, :campaign_negative_placements_performance_report,
        :ad_extensions_performance_report, :destination_url_report, :creative_conversion_report,
        :call_metrics_call_details_report, :criteria_performance_report]
      if symbols.include?(symbol)
        @report_type = symbol
      else
        puts "Invalid report_type: #{symbol}"
      end
    end

    def date_range_type=(symbol)
      symbols = [:today, :yesterday, :last_7_days, :last_week, :last_business_week,
        :this_month, :last_month, :all_time, :custom_date, :last_14_days, :last_30_days,
        :this_week_sun_today, :this_week_mon_today, :last_week_sun_sat]
      if symbols.include?(symbol)
        @date_range_type = symbol
      else
        puts "Invalid date_range_type: #{symbol}"
      end
    end

    def definition
      definition = {
        selector: Toolkit.selector([:campaign_id, :id, :click_type, :impressions, :clicks, :cost]),
        report_name: self.report_name,
        report_type: self.report_type.to_s.upcase,
        download_format: self.download_format.to_s.upcase,
        date_range_type: self.date_range_type.to_s.upcase,
        include_zero_impressions: self.include_zero_impressions
      }
      definition[:selector][:date_range] = self.date_range if self.date_range
      definition
    end

    def perform_find
      puts definition
      self.execute(:download_report, definition)
    end

  end
end
