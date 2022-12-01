class Cost < ApplicationRecord
  belongs_to :user
  has_many :cost_notes
  has_many :notes, :through => :cost_notes
end
