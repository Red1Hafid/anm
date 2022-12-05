class Cost < ApplicationRecord
  validates :name, presence: true, format: {with: /[a-zA-Z]/}, uniqueness: true

  has_many :notes
  has_many :users, through: :notes
end
