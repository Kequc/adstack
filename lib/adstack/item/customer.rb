module Adstack
  class Customer < Item

    field :name,                :f, :roc, :s
    field :login,               :f, :ro, :s
    field :company_name,        :f, :ro, :s
    field :customer_id,         :f, :ro, :s
    field :can_manage_clients,  :f, :ro, :s
    field :currency_code,       :f, :roc, :s, l: [3, 3]
    field :date_time_zone,      :f, :roc, :s

    service_api :managed_customer, r: :customer, p: :customer_id

    customer_id_free

    def perform_save
      return false if self.persisted?
      super
    end

  end
end
