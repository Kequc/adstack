module Adstack::Deleteable
  extend ActiveSupport::Concern

  # Attributes to use for delete operation
  def delete_operation
    self.writeable_attributes(self.class.required | [self.class.primary_key])
  end

  # Delete it
  def perform_delete
    self.mutate_explicit('REMOVE', self.delete_operation)
    self.deprovision
    true
  end

  def delete
    return true unless self.persisted?
    self.perform_delete
  end

  module ClassMethods

    def deleteable?
      true
    end
    
  end

end
