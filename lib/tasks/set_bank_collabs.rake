require 'date'

desc "Calcul furlough balance of all users since the date of integration for the first time"
task set_bank_collabs: :environment do
    puts 'Start calcul of furlough balance'
        users = User.where(is_active: true).includes(:bank)
        setting = Setting.find(1)
        traitement_date = Date.today.strftime('%Y-%m %l:%M %p').split.first.gsub("-", "")
     
        users.each do |user|
            started_at_user = user.started_at.strftime('%Y-%m %l:%M %p').split.first.gsub("-", "")
            if started_at_user.to_i < traitement_date.to_i
                days_worked_between_two_date = (user.started_at..Date.today.prev_month.end_of_month).to_a.select {|k| [1,2,3,4,5,6].include?(k.wday)} 
                furloughs = Furlough.furlough_between(user.started_at, Date.today.prev_month.end_of_month, user.id)
            
                furloughs_duration = 0.0
                furloughs.each do |furlough|  
                    furlough_end = furlough[2].to_date.strftime('%Y-%m-%d %l:%M %p').split.first.gsub("-", "")
                    end_date = Date.today.prev_month.end_of_month.strftime('%Y-%m-%d %l:%M %p').split.first.gsub("-", "")
                        
                    if furlough_end.to_i < end_date.to_i
                        furlough_duration += Furlough.get_furlough_duration(furlough[0], furlough[1], furlough[2], furlough[3])
                    else
                        excluded_duration = Furlough.get_furlough_duration(Date.today.prev_month.end_of_month, "8:00", furlough[2], furlough[3]) 
                        furlough_duration = Furlough.get_furlough_duration(furlough[0], furlough[1], furlough[2], furlough[3])
                        included_duration = furlough_duration - excluded_duration
                        furloughs_duration += included_duration
                    end  
                end
                
                days_worked = days_worked_between_two_date.count - furloughs_duration
                last_balance_furlough = user.bank.balance_furlough
                balance_furlough = (setting.month_balance / ENV['BASE_DAYS_WORKED'].to_f ) * days_worked

                user.bank.update(balance_furlough: last_balance_furlough + balance_furlough.to_f)          
            end
        end   
    puts 'End calcul of furlough balance'
end
