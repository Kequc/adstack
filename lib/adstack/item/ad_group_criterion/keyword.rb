module Adstack
  class Keyword < AdGroupCriterion

    field :text,        :f, :r, :s, m: /[^\x00]*/
    field :match_type,  :f, :r, :s, w: %w{EXACT PHRASE BROAD}

  end
end
