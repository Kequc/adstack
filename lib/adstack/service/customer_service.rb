module Adstack
  class CustomerService < Service

    service_api :managed_customer, r: :customer

    customer_id_free

  end
end
