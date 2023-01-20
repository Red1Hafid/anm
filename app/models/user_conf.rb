class UserConf < ApplicationRecord
  belongs_to :user

  has_one_attached :cachet
end
