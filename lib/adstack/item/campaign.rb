module Adstack
  class Campaign < Item

    field :id,                :f, :ro, :s
    field :name,              :f, :s,           l: 1
    field :status,            :f, :s,           w: %w{ACTIVE DELETED PAUSED}
    field :serving_status,    :f, :ro, :s
    field :start_date,        :f, :s,           t: :date
    field :end_date,          :f, :s,           t: :date
    field :budget,                              h: Budget
    field :bidding_strategy,  :roc, :p,         d: { xsi_type: 'BudgetOptimizer' }
    field :ad_serving_optimization_status,  :s, w: %w{OPTIMIZE ROTATE UNAVAILABLE}
    field :frequency_cap
    field :settings,          :ro, :s, :p
    field :network_setting,                     h: NetworkSetting

    service_api :campaign

    cannot_delete :set_status

    parent :customer

    def child_params
      super(campaign_id: self.id)
    end

    def bidding_strategy=(bidding_strategy)
      bidding_strategy = { xsi_type: bidding_strategy } unless bidding_strategy.is_a?(Hash)
      @bidding_strategy = bidding_strategy
    end

    def activate
      self.update_attributes(status: 'ACTIVE')
    end

    def pause
      self.update_attributes(status: 'PAUSED')
    end

    def rename(new_name)
      self.update_attributes(name: new_name)
    end

    def rollback
      puts "ROLLING BACK CAMPAIGN: \"#{self.name}\""
      self.delete
    end

    def writeable_attributes(symbols=nil)
      result = super
      return result if self.persisted?
      result.merge!(settings: [
        {
          :xsi_type => 'KeywordMatchSetting',
          :opt_in => true
        }
      ])
      result
    end

  end
end
