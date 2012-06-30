module Adstack
  class Account < Item

    field :customer_id,       :ro
    field :login,             :ro
    field :company_name,      :ro
    field :can_manage_clients, :ro
    field :currency_code,     :r, l: [3, 3]
    field :date_timezone,     :r
    field :descriptive_name,  :r, l: [1, 255]

    primary :customer_id

    service_name :create_account, :i

    def save_operation
      if self.persisted?
        Toolkit.operation('SET', super)
      else
        {
          :operator => 'ADD',
          :operand => {
            :currency_code => @currency_code,
            :date_time_zone => @date_time_zone
          },
          :descriptive_name => @descriptive_name
        }
      end
    end

    def perform_save
      Api.mutate(self.service_name, self.save_operation)
    end

    def response_location
      0
    end

  end
end
