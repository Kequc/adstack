module Adstack
  class Campaign < Item

    field :id,                :f, :ro, :s
    field :name,              :f, :s, l: 1
    field :status,            :f, :s, w: %w{ACTIVE DELETED PAUSED}
    field :serving_status,    :f, :ro, :s
    field :start_date,        :f, :s
    field :end_date,          :f, :s
    field :budget
    field :bidding_strategy,  :r
    field :conversion_optimizer_eligibility, :ro
    field :campaign_stats,    :ro
    field :ad_serving_optimization_status, :s, w: %w{OPTIMIZE ROTATE UNAVAILABLE}
    field :frequency_cap
    field :settings,          :s
    field :network_setting

    service_api :campaign

    cannot_delete :set_status

    parent :account

    children :campaign_criterion, :ad_group, :ad_extension

    def child_attributes
      super(campaign_id: self.id)
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

  end
end
