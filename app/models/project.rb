class Project < ApplicationRecord
  validates :name, presence: true, format: {with: /[a-zA-Z]/}, uniqueness: true

  has_many :affectations
  has_many :users, through: :affectations

  enum status: {
    created: 1,
    deleted: 2,
  }

  scope :filter_by_status, -> (status) { where('project.status = ?', status) }

end
