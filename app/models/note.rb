class Note < ApplicationRecord
  has_many :cost_notes
  has_many :costs, :through => :cost_notes
end
