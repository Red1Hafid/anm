class Note < ApplicationRecord
  validates :name, presence: true, format: {with: /[a-zA-Z]/}
  #validates :total, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100 }

  belongs_to :user
  belongs_to :cost

  has_one_attached :documment
end
