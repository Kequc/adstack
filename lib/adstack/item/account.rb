module Adstack
  class Account < Item

    field :customer_id,       :ro
    field :login,             :ro
    field :company_name,      :ro
    field :can_manage_clients, :ro
    field :currency_code,     :r, l: [3, 3]
    field :date_timezone,     :r
    field :descriptive_name,  :r, l: [1, 255]

    service_api :create_account, r: :account, p: :customer_id, l: 0

    customer_id_free

    cannot_delete

    children :campaign

    def save_operation
      operand = super
      descriptive_name = operand.delete(:descriptive_name)
      {
        :operator => self.save_operator,
        :operand => operand,
        :descriptive_name => descriptive_name
      }
    end

    def perform_save
      mutate(self.save_operation)
    end

    def self.find(amount)
      AccountService.find(amount)
    end

  end
end
