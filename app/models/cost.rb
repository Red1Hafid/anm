class Cost < ApplicationRecord
  validates :name, presence: true, format: {with: /[a-zA-Z]/}, uniqueness: true

  has_many :notes
  has_many :users, through: :notes

  enum status: {
    created: 1,
    deleted: 2,
  }

  scope :filter_by_status, -> (status) { where('costs.status = ?', status) }
end
