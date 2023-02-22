class AdditionalHour < ApplicationRecord
  acts_as_tenant :company
  belongs_to :user
  belongs_to :additional_hour_type

  validates :total_additional_hour_in_week, presence: true

  enum status: {
    created: 1,
    aprouved: 2,
    expired: 3
  }

  def self.exported_data_filtred(additional_hours, params)
    additional_hours = additional_hours.where(period: params[:period_additional_hour])
    
    if params[:type_additional_hours] == "Tous"
      additional_hours_type = AdditionalHourType.where(code: ['HSJFT','HSJO'])
      additional_hours = additional_hours.where(additional_hour_type_id: additional_hours_type)
    else
      additional_hours_type = AdditionalHourType.where(code: params[:type_additional_hours])
      additional_hours = additional_hours.where(additional_hour_type_id: additional_hours_type)
    end

    if params[:collaborateurs] != 'Tous'
      user = User.where(email: params[:collaborateurs]).first
      additional_hours = additional_hours.where(user_id: user.id)
    end
      
    return additional_hours
  end

  def self.update_etat_additional_hours(specification, furlough)
    specification[:results][:additional_hours].each_with_index do |additional_hour_id, i|
      additional_hour = AdditionalHour.find(additional_hour_id)
      additional_hour.consumed_hours.push(specification[:results][:consumed_hours][i])
      additional_hour.stay_hours -= specification[:results][:stay_hours][i]
      if additional_hour.consumed_hours.sum == additional_hour.total_additional_hour_in_week
        additional_hour.is_done = true
      end
      additional_hour.save
    end
   
    bank = Bank.find_by(user_id: furlough.user_id)
    furlough_duration = Furlough.get_hour_furlough_duration(furlough.start, furlough.hour_start, furlough.end, furlough.hour_end)
    furlough_balance = bank.balance_open_additional_hour_off_days
    balance = furlough_balance - furlough_duration
    bank.update(balance_open_additional_hour_off_days: balance)
  end

  def self.custom_finder(period, code, user_id)
    additional_hour_type_id = AdditionalHourType.find_by(code: code).id
    additional_hours = AdditionalHour.find_by(period: period, additional_hour_type_id: additional_hour_type_id, user_id: user_id)
    if additional_hours.present?
     return true
    else
      return false
    end
  end

end
