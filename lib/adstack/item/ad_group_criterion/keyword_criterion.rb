module Adstack
  class KeywordCriterion < AdGroupCriterion

    field :text,        :f, :r, :s, e: :criterion, m: /[^\x00]*/
    field :match_type,  :f, :r, :s, e: :criterion, w: %w{EXACT PHRASE BROAD}

    kind :ad_group_criterion

  end
end
