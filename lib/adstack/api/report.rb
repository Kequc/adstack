module Adstack
  class Report < Api

    def service_init
      self.adwords.report_utils(API_VERSION)
    end

    def self.find(params={})
      params.symbolize_all_keys!

      download_formats = [:csvforexcel, :csv, :tsv, :xml, :gzipped_csv, :gzipped_xml]
      report_types = [:keywords_performance_report, :ad_performance_report, :url_performance_report,
        :adgroup_performance_report, :campaign_performance_report, :account_performance_report, :geo_performance_report,
        :search_query_performance_report, :managed_placements_performance_report, :automatic_placements_performance_report,
        :campaign_negative_keywords_performance_report, :campaign_negative_placements_performance_report,
        :ad_extensions_performance_report, :destination_url_report, :creative_conversion_report,
        :call_metrics_call_details_report, :criteria_performance_report]
      date_range_types = [:today, :yesterday, :last_7_days, :last_week, :last_business_week,
        :this_month, :last_month, :all_time, :custom_date, :last_14_days, :last_30_days,
        :this_week_sun_today, :this_week_mon_today, :last_week_sun_sat]

      params[:download_format] = :xml unless download_formats.include?(params[:download_format])
      params[:report_type] = "A Report" unless report_types.include?(params[:report_type])
      params[:date_range_type] = :last_7_days unless date_range_types.include?(params[:date_range_type])
      params[:include_zero_impressions] ||= false

      # Custom date
      date_range = !!(params[:date_range] or params[:date_range_type] == :custom_date) ? {} : nil

      if date_range
        params[:date_range_type] = :custom_date
        # Format dates to strings
        params[:date_range].each_pair { |k,v| date_range[k] = v.to_datetime.simple } rescue nil

        if date_range[:min].blank? or date_range[:max].blank?
          params[:date_range_type] = :last_7_days
          use_custom_date = false
        end
      end

      definition = {
        selector: Toolkit.selector([:campaign_id, :id, :click_type, :impressions, :clicks, :cost]),
        report_name: params[:report_name],
        report_type: params[:report_type].to_s.upcase,
        download_format: params[:download_format].to_s.upcase,
        date_range_type: params[:date_range_type].to_s.upcase,
        include_zero_impressions: params[:include_zero_impressions]
      }
      definition[:selector][:date_range] = date_range if date_range

      Api.execute(nil, :download_report, definition)
    end

  end
end
