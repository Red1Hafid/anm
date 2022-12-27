class Affectation < ApplicationRecord
  validates :date_disacffectation, presence: true

  belongs_to :user
  belongs_to :project
end
