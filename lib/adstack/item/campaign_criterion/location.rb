module Adstack
  class Location < CampaignCriterion

    field :location_name,     :f, :ro, :s,    e: :criterion
    field :display_type,          :ro, :s,    e: :criterion
    field :targeting_status,      :ro, :s,    e: :criterion
    field :parent_locations,      :ro, :s,    e: :criterion

    kind :location

    def id=(id)
      set_attributes(id: id)
    end
    validates_presence_of :id

  end
end
