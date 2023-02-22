class FonctionalManager < ApplicationRecord
    validates :first_name, presence: true
    validates :last_name, presence: true

    acts_as_tenant :company

    def full_name_user
        "#{first_name} #{last_name}"
    end

    def self.full_name(user_id)
        user=FonctionalManager.find(user_id)
        user.first_name + " " + user.last_name
    end
end
