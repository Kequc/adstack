module Adstack
  class AdGroupCriterion < Item
    include Adstack::Deleteable

    field :ad_group_id,             :f, :r, :s
    field :criterion_use,           :f, :ro, :s, w: %w{BIDDABLE NEGATIVE}

    field :id,                      :f, :ro, :s,  e: :criterion

    service_api :ad_group_criterion

    parent :ad_group

    kind_lookup :criteria_type, :criterion, :criterion_type

  end
end
