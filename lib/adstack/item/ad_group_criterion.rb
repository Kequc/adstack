module Adstack
  class AdGroupCriterion < Item

    field :ad_group_id,     :f, :r, :s
    field :criterion_use,   :f, :ro, :s

    field :id,              :f, :ro, :s,  e: :criterion
    field :type,            :f, :ro, :s,  e: :criterion
    field :criterion_type,  :ro,          e: :criterion

    service_api :ad_group_criterion

    cannot_delete :set_status

    parent :ad_group

  end
end
