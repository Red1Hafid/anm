class Journal < ApplicationRecord
    acts_as_tenant :company
    belongs_to :user, optional: true

    def self.create_journal(role, user, action, model, model_identity, object_identity, object_id, status)
        if action == "importé" || action == "exporté"
            content = "le #{role} #{user.first_name} #{user.last_name} a #{action} #{model_identity} - loger le : #{Time.now}"
        else
            content = "le #{role} #{user.first_name} #{user.last_name} a #{action} #{model_identity} (#{object_identity}) - loger le : #{Time.now}"
        end
        @journal = Journal.new
        @journal.content = content
        @journal.the_model = model
        @journal.the_model_id = object_id
        @journal.user_id = user.id
        @journal.status = status
        @journal.save 
    end
end
