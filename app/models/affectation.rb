class Affectation < ApplicationRecord
  validates :date_affectation, presence: true

  belongs_to :user
  belongs_to :project


  enum status: {
    affected: 1,
    disaffected: 2,
  }
end
