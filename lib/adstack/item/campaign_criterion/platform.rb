module Adstack
  class Platform < CampaignCriterion

    attr_writer :id

    field :platform_name, :ro, :s, e: :criterion

    kind :platform

    can_batch

    validates_presence_of :id

    def persisted?
      !!self.platform_name.present?
    end

    def deprovision(symbols=nil)
      symbols = Array.wrap(symbols) | [:platform_name]
      super(symbols)
    end

    def delete_operation
      self.writeable_attributes(self.class.required | [self.class.primary_key])
    end

  end
end
