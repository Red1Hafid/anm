class Note < ApplicationRecord
  validates :name, presence: true, format: {with: /[a-zA-Z]/}
  validates :total, numericality: { greater_than: 0}, presence: true

  acts_as_tenant :company

  scope :mes_notes,  -> (userId) { where( user_id: userId) }

  belongs_to :user
  belongs_to :cost
  belongs_to :project

  has_one_attached :documment
  validates_associated :documment, :content_type => { :content_type => %w(application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document) }

end
