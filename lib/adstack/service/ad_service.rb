module Adstack
  class AdService < Service

    required :ad_group_id

    parents :text_ad

    def item(params={})
      new_from(params, :ad, :ad_type)
    end

    def find_operation
      Api.get(:ad_group_ad, self.selector(:name), self.predicates)
    end

  end
end
