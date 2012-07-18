module Adstack
  class Account < Item

    field :customer_id,       :ro
    field :login,             :ro
    field :company_name,      :ro
    field :can_manage_clients, :ro
    field :currency_code,     :roc, :p, l: [3, 3]
    field :date_time_zone,     :roc, :p
    field :descriptive_name,  :r, l: [1, 255]

    service_api :create_account, r: :account, p: :customer_id

    customer_id_free

    cannot_delete

    def save_operation
      operand = super
      descriptive_name = operand.delete(:descriptive_name)
      {
        :operator => self.operator,
        :operand => operand,
        :descriptive_name => descriptive_name
      }
    end

    def perform_save
      {value: mutate(self.save_operation)}
    end

  end
end
