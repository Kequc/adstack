module Adstack
  class Platform < CampaignCriterion

    field :platform_name, :ro, :s, e: :criterion

    kind :platform

    def persisted?
      !!self.platform_name.present?
    end

    def deprovision(symbols=nil)
      symbols = Array.wrap(symbols) | [:platform_name]
      super(symbols)
    end

    def writeable_attributes(list=nil)
      result = super(list)
      result[:criterion].merge!(xsi_type: 'Platform')
      result
    end

  end
end
