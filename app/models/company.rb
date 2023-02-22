class Company < ApplicationRecord
    validates :name, :subdomain, :domain, uniqueness: true
end
