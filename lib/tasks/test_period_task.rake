require 'date'

desc "Validate the collaborateur as soon as he exceeds 6 months since his integration date "
task test_period_task: :environment do
    puts 'Start calcul of furlough balance'
      users = User.where(is_active: true)
      setting = Setting.find(1)
      traitement_date = Date.today
     
      users.each do |user|
        started_at_user = user.started_at

        months_diff = (traitement_date.year * 12 + traitement_date.month) - (started_at_user.year * 12 + started_at_user.month)

        if started_at_user.day > traitement_date.day && !((started_at_user == started_at_user.end_of_month || traitement_date.month == 2) && (traitement_date == traitement_date.end_of_month))
            months_diff = months_diff - 1
        end

        puts months_diff

        if months_diff > 6
            #user.update(is_valide: true)
        end

      end   
    
    puts 'End calcul of furlough balance'
end
