module Adstack
  class TextAd < Ad

    field :headline,      :f, :s, e: :ad
    field :description1,  :f, :s, e: :ad
    field :description2,  :f, :s, e: :ad

    kind :ad

  end
end
