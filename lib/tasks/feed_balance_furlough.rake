require 'date'

desc "Calcul furlough balance of all users"
task feed_balance_furlough: :environment do
    puts 'Start calcul of furlough balance'
      users = User.where(is_active: true).includes(:bank)
      setting = Setting.find(1)
      traitement_date = Date.today.strftime('%Y-%m %l:%M %p').split.first.gsub("-", "")
      prev_date = Date.today.prev_month.strftime('%Y-%m %l:%M %p').split.first.gsub("-", "")
     
      users.each do |user|
        started_at_user = user.started_at.strftime('%Y-%m %l:%M %p').split.first.gsub("-", "")

        if started_at_user.to_i < traitement_date.to_i

          if started_at_user.to_i == prev_date.to_i 
            days_worked = Furlough.get_days_worked_between_two_date(user, user.started_at, user.started_at.end_of_month)
          else
            days_worked = Furlough.get_days_worked_between_two_date(user, Date.today.prev_month.beginning_of_month, Date.today.prev_month.end_of_month)
          end

          last_balance_furlough = user.bank.balance_furlough
          if days_worked >= ENV['BASE_DAYS_WORKED'].to_f
              user.bank.update(balance_furlough: last_balance_furlough + setting.month_balance)
          else
              balance_furlough = (setting.month_balance / ENV['BASE_DAYS_WORKED'].to_f ) * days_worked
              user.bank.update(balance_furlough: last_balance_furlough + balance_furlough.to_f)
          end
        end
      end   
    
    puts 'End calcul of furlough balance'
end
