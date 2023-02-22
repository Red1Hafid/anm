class UserConf < ApplicationRecord
  acts_as_tenant :company
  belongs_to :user

  has_one_attached :cachet
end
