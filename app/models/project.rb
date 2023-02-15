class Project < ApplicationRecord
  before_validation :generate_reference, on: :create
  
  validates :name, presence: true, format: {with: /[a-zA-Z]/}, uniqueness: true
  
  acts_as_tenant :company

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
    return if self.reference != nil
    project = Project.last
    if project
      reference = "PJ#" + (project.id + 1).to_s
    else
      reference = "PJ#1"
    end

    self.reference = reference
    set_reference if Project.find_by(reference: reference)
  end

end
