class Bank < ApplicationRecord
    acts_as_tenant :company
end
