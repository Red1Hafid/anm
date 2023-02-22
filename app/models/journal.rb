class Journal < ApplicationRecord
    acts_as_tenant :company
    belongs_to :user, optional: true

    def self.create_journal(user, furlough, status, content, model)
        @journal = Journal.new
        @journal.content = content
        @journal.the_model = model
        @journal.the_model_id = furlough.id
        @journal.user_id = user.id
        @journal.status = status
        @journal.save 
    end
end
