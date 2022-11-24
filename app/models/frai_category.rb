class FraiCategory < ApplicationRecord
 validates :name, presence: true, format: {with: /[a-zA-Z]/}
end
