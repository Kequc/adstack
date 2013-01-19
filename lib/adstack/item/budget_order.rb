module Adstack
  class BudgetOrder < Item
    include Adstack::Updateable

    attr_writer :date_time_zone

    field :billing_account_id,  :f, :roc, :s
    field :id,                  :f, :s
    field :spending_limit,      :f, :roc, :s, h: Money
    field :start_date_time,     :f, :roc, :s, t: :time_zone
    field :end_date_time,       :f, :roc, :s, t: :time_zone

    service_api :budget_order

    parent :customer

    def initialize(params={})
      params.symbolize_keys!
      params[:billing_account_id] ||= Config.get(:billing_account_id)
      self.date_time_zone = params.delete(:date_time_zone)
      super(params)
    end

    def date_time_zone
      @date_time_zone.present? ? @date_time_zone : super
    end

    def has_started?
      return false unless self.persisted?
      return false unless self.start_date_time.present?
      self.start_date_time <= Time.now
    end

    def is_current?
      return false unless self.has_started?
      return false unless self.end_date_time.present?
      self.end_date_time >= Time.now
    end

    def end_immediately
      self.update_attributes(end_date_time: Time.now+30) if self.is_current?
    end

    def writeable_attributes(symbols=nil)
      result = super(symbols)
      if self.has_started?
        result.delete(:start_date_time)
      elsif !result[:start_date_time].present? or self.start_date_time < Time.now+60
        result[:start_date_time] = Toolkit.string_time_zone(Time.now+60, self.date_time_zone)
      end
      result
    end

  end
end
