class CostNote < ApplicationRecord
  belongs_to :note
  belongs_to :cost
end