module Adstack
  class Keyword < AdGroupCriterion

    attr_accessor :negative

    field :text,        :f, :roc, :s, :p, e: :criterion, m: /[^\x00]*/
    field :match_type,  :f, :roc, :s, :p, e: :criterion, w: %w{EXACT PHRASE BROAD}

    kind :keyword

    cannot_update

    can_batch

    def writeable; @writeable ||= [:xsi_type]; end

    def initialize(params={})
      if params.is_a? String
        params = Keyword.params_from_string(params)
      else
        params.symbolize_all_keys!
      end
      self.negative = !!params[:negative] || (params[:xsi_type] == "NegativeAdGroupCriterion")
      super(params)
    end

    def xsi_type
      self.negative ? "NegativeAdGroupCriterion" : "BiddableAdGroupCriterion"
    end

    def self.params_from_string(str)
      match_type = case str[0]
      when '"'
        str = str.slice(1, (str.size - 2))
        'PHRASE'
      when '['
        str = str.slice(1, (str.size - 2))
        'EXACT'
      else
        'BROAD'
      end
      # Keyword is negative
      neg = false
      if (str =~ /^\-/)
        str.slice!(0, 1)
        neg = true
      end
      # Keyword
      { text: str, match_type: match_type, negative: neg }
    end

    def self.new_from_string(str)
      new(self.params_from_string(str))
    end

    def to_s
      result = self.text
      result = "-%s" % self.text if self.negative

      case self.match_type
      when 'PHRASE'
        "\"%s\"" % result
      when 'EXACT'
        "[%s]" % result
      else
        result
      end
    end

    def attributes(list=nil, embedded=:attributes)
      list ||= self.all_attributes
      list << :negative
      super(list, embedded)
    end

    def writeable_attributes(list=nil)
      super(list).merge(xsi_type: self.xsi_type)
    end

  end
end
