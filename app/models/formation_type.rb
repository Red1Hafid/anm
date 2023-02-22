class FormationType < ApplicationRecord
    acts_as_tenant :company
end
