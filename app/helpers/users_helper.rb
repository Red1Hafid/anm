module UsersHelper
    def get_grounds(action_id)
       grounds = Ground.where(stop_action_id: action_id).order(created_at: :asc)
       return grounds
    end
end
