class Note < ApplicationRecord
  validates :name, presence: true, format: {with: /[a-zA-Z]/}
  validates :total, numericality: { greater_than: 0}, presence: true

  belongs_to :user
  belongs_to :cost

  has_one_attached :documment
  validates_associated :documment, :content_type => { :content_type => %w(application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document) }


  def self.update_note
    if attachment.present? && attachment_changed?
      self.original_filename = attachment.file.original_filename
      self.content_type = attachment.file.content_type
    end
  end
end
