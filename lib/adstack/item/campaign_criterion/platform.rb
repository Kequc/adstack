module Adstack
  class Platform < CampaignCriterion

    field :platform_name, :ro, :s, e: :criterion

    kind :platform

    def writeable_attributes(list=nil)
      result = super(list)
      result[:criterion].merge!(xsi_type: 'Platform')
      result
    end

  end
end
