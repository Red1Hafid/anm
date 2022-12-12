class Note < ApplicationRecord
  validates :name, presence: true, format: {with: /[a-zA-Z]/}
  validates :total, numericality: { greater_than: 0}, presence: true

  belongs_to :user
  belongs_to :cost

  has_one_attached :documment
end
