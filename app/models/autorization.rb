class Autorization < ApplicationRecord
  serialize :history, Array
  
  acts_as_tenant :company
  belongs_to :user

  enum status: {
    created: 1,
    encours: 2,
    soumis: 3,
    aprouved: 4,
    refuse: 5
  }

  scope :count_authorisations, lambda{|month, user_id| where('EXTRACT(MONTH FROM autorizations.date) = ? AND autorizations.user_id = ?', month, user_id).where.not(status: 5)}
  scope :filter_by_status, -> (status) { where('autorizations.status = ?', status) }
  scope :filter_by_all_status, -> (status) { where status: status }
  scope :filter_by_sup_date, -> (date) { where("autorizations.date > ?", date) }
  scope :filter_by_inf_date, -> (date) { where("autorizations.date < ?", date) }
  scope :filter_by_egal_date, -> (date) { where("autorizations.date like ?", date) }
  scope :filter_by_recovery_method, -> (recovery_method) { where("autorizations.recovery_method like ?", recovery_method)}
  scope :filter_by_all_recovery_method, -> (recovery_methods) { where recovery_method: recovery_methods }



  def self.get_hour_authorization_duration(d1, h1, h2)

    if (Furlough.is_week_day(d1.to_date) == true || Off.is_off(d1.to_date) == true)
      count_hour_furlough = 0
    elsif (Furlough.is_week_day(d1.to_date) == false || Off.is_off(d1.to_date) == false) 
      if (h1.split(/: */).first.to_i < 13) && (h2.split(/: */).first.to_i > 13)
        count_hour_furlough =  h2.split(/: */).first.to_i - h1.split(/: */).first.to_i - 2
      elsif (h1.split(/: */).first.to_i > 13) && (h2.split(/: */).first.to_i < 13)
        count_hour_furlough = 0 
      elsif (h1.split(/: */).first.to_i > 13) && (h2.split(/: */).first.to_i > 13)
        if h1.split(/: */).first.to_i > h2.split(/: */).first.to_i
          count_hour_furlough = 0
        else
          count_hour_furlough =  h2.split(/: */).first.to_i - h1.split(/: */).first.to_i
        end
      elsif (h1.split(/: */).first.to_i < 13) && (h2.split(/: */).first.to_i < 13)
        if h1.split(/: */).first.to_i > h2.split(/: */).first.to_i
          count_hour_furlough = 0
        else
          count_hour_furlough =  h2.split(/: */).first.to_i - h1.split(/: */).first.to_i
        end
      end
    end
   
    return count_hour_furlough
  end

  def self.custom_finder(date, start_hour, end_hour, user_id)
    authorization = Autorization.find_by(date: date, start_hour: start_hour, end_hour: end_hour, user_id: user_id)
    if authorization.present?
     return true
    else
      return false
    end
  end

  def self.search(params)     
    where("title LIKE ?", "%#{params[:search]}%") if params[:search].present? 
  end

end
