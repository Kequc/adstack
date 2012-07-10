module Adstack
  class Location < CampaignCriterion

    field :location_name,     :f, :ro, :s,  e: :criterion
    field :display_type,      :ro, :s,      e: :criterion
    field :targeting_status,  :ro, :s,      e: :criterion
    field :parent_locations,  :ro, :s,      e: :criterion

    kind :location

    def writeable_attributes(list=nil)
      result = super(list)
      result[:criterion].merge!(xsi_type: 'Location')
      result
    end

  end
end
