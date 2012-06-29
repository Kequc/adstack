module Adstack
  class AdGroupCriterion < Item

    field :ad_group_id,   :less, :f, :r, :s
    field :criterion_use, :less, :f, :ro, :s
    field :criterion,     :less, :r

    field :id,            :f, :ro, :s
    field :criteria_type, :f, :ro, :s

    primary :id

    def writeable_attributes
      # This is a layered class
      self.writeable_attributes(true).merge(criterion: super)
    end

    def save_operation
      Api.mutate_explicit(:ad_group, self.o, self.writeable_attributes)
    end

    def delete_operation
      self.update_attributes(name: Toolkit.delete_name(self.name), status: 'DELETED')
    end

  end
end
