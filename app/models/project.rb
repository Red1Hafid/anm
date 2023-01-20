class Project < ApplicationRecord
  validates :name, presence: true, format: {with: /[a-zA-Z]/}, uniqueness: true
  before_validation :generate_reference, on: :create

  scope :filter_by_status, -> (status) { where('project.status = ?', status) }

  has_many :notes
  has_many :affectations
  has_many :users, through: :affectations

  enum status: {
    created: 1,
    deleted: 2,
  }

  private

  def generate_reference
    self.reference = SecureRandom.hex(2)
    while Project.exists?(reference: self.reference)
      self.reference = SecureRandom.hex(2)
    end
  end

end
