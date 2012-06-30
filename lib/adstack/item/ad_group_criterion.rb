module Adstack
  class AdGroupCriterion < Item

    field :ad_group_id,   :f, :r, :s
    field :criterion_use, :f, :ro, :s

    field :id,            :f, :ro, :s, e: :criterion
    field :criteria_type, :f, :ro, :s, e: :criterion

    primary :id

    service_name :ad_group_criterion

    kinds :keyword

    def delete_operation
      self.update_attributes(name: Toolkit.delete_name(self.name), status: 'DELETED')
    end

  end
end
