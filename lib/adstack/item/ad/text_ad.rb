module Adstack
  class TextAd < Ad

    field :headline,      :f, :s, :p, e: :ad
    field :description1,  :f, :s, :p, e: :ad
    field :description2,  :f, :s, :p, e: :ad

    kind :text_ad

    def writeable_attributes(list=nil)
      result = super(list)
      result[:ad].merge!(xsi_type: 'TextAd')
      result
    end

  end
end
