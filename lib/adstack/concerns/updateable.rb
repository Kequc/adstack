module Adstack::Updateable
  extend ActiveSupport::Concern

  # Save it
  def perform_save
    self.mutate_explicit(self.operator, self.save_operation)
  end

  # Update and save
  def update_attributes(params)
    self.attributes = params
    self.save
  end
  alias_method :set, :update_attributes

  # Delete it
  def perform_delete
    params = { status: 'DELETED' }
    params.merge!(name: Toolkit.delete_name(self.name)) if self.respond_to?(:name)
    self.update_attributes(params)
    true
  end

  def delete
    return true unless self.persisted?
    self.perform_delete
  end

  module ClassMethods

    def updateable?
      true
    end
    
  end

end
