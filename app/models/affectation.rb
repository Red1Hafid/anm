class Affectation < ApplicationRecord
  validates :date_affectation, presence: true

  scope :mes_affectation,  -> (userId) { where(user_id: userId) }
  scope :filter_by_status, -> (status ){ where( status: status) }

  belongs_to :user
  belongs_to :project


  enum status: {
    affected: 1,
    disaffected: 2,
  }

  def self.custom_finder(user_id, project_id)
    affectation = Affectation.find_by(user_id: user_id, project_id: project_id, is_active: true)
    if affectation.present?
      return true
    else
      return false
    end
  end
end
