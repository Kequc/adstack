module Adstack
  class Account < Item

    field :customer_id,   :ro
    field :login,         :ro
    field :company_name,  :ro
    field :can_manage_clients, :ro
    field :currency_code, :r, l: [3, 3]
    field :date_timezone, :r
    field :descriptive_name, :r, l: [1, 255]

    primary :customer_id

    def save_operation
      if self.persisted?
        response = Api.mutate_explicit(:create_account, self.o, self.writeable_attributes)
      else
        operation = {
          :operator => self.o,
          :operand => {
            :currency_code => @currency_code,
            :date_time_zone => @date_time_zone
          },
          :descriptive_name => @descriptive_name
        }
        response = Api.mutate(:create_account, operation)
      end
    end

    def response_location
      0
    end

  end
end
