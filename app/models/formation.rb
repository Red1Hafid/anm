class Formation < ApplicationRecord
  acts_as_tenant :company
  belongs_to :user
  belongs_to :formation_type
end
