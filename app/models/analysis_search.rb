class AnalysisSearch
    attr_reader :date_from, :date_to

    def initialize(params)
        params ||= {}
        @date_from = parsed_date(params[:date_from], Date.today.at_beginning_of_month)
        @date_to = parsed_date(params[:date_to], Date.today)
    end

    def get_analysis_between_two_date(user, start_d, end_d)
      analysis = []
      setting = Setting.find(1)

      if ['Collaborateur'].include? user.role.title
        users = User.where(id: user.id)
      else
        role_id = Role.find_by(title: "Super Admin").id
        users = User.where(is_active: true).where.not(role_id: role_id)
      end

      users.each do |user|
        user_started_at_date = user.started_at.strftime('%Y%m%d')
        start_date = start_d.strftime('%Y%m%d')
        end_date = end_d.strftime('%Y%m%d')

        days_off_between_two_date_exact = []
        days_worked_between_two_date = Furlough.get_days_worked_between_two_date(user, start_d, end_d) 

        if user_started_at_date.to_i >= end_date.to_i
          day_off_consumed = []
          all_day_off_consumed = []
        else
          if user_started_at_date.to_i < start_date.to_i
            off_days = Off.off_between(start_d, end_d)
            if !off_days.empty?
              off_days.each do |off|
                days_off_between_two_date = (off.start.to_date..off.end.to_date).to_a.select {|k| [1,2,3,4,5,6].include?(k.wday)} 
                days_off_between_two_date_exact << days_off_between_two_date.uniq.select { |date| date.to_date >= start_d && date.to_date < end_d }  
              end
            end

            day_off_consumed = []
            days_off_between_two_date_exact.each do |off|
              off.each do |o|
                day_off_consumed.push(o)
              end
            end
          else
            off_days = Off.off_between(user.started_at.to_date, end_d)
  
            if !off_days.empty?
              off_days.each do |off|
                days_off_between_two_date = (off.start.to_date..off.end.to_date).to_a.select {|k| [1,2,3,4,5,6].include?(k.wday)} 
                days_off_between_two_date_exact << days_off_between_two_date.uniq.select { |date| date.to_date >= user.started_at.to_date && date.to_date < end_d }  
              end
            end
  
            day_off_consumed = []
            days_off_between_two_date_exact.each do |off|
              off.each do |o|
                day_off_consumed.push(o)
              end
            end
          end

          all_days_off_between_off_exact = []
          all_off_days = Off.off_between(user.started_at.to_date, Date.today)
          if !all_off_days.empty?
            all_off_days.each do |off|
              all_days_off_between_off = (off.start.to_date..off.end.to_date).to_a.select {|k| [1,2,3,4,5,6].include?(k.wday)} 
              all_days_off_between_off_exact << all_days_off_between_off.uniq.select { |date| date.to_date >= user.started_at.to_date && date.to_date < Date.today }  
            end
          end

          all_day_off_consumed = []
          all_days_off_between_off_exact.each do |off|
            off.each do |o|
              all_day_off_consumed.push(o)
            end
          end
        end

        balance_furlough = (setting.month_balance.to_f / ENV['BASE_DAYS_WORKED'].to_f ) * days_worked_between_two_date
        balance_d = balance_furlough.round(2)
        balance_h = (balance_d * setting.day_work_hour).round(2)
        b_furlough_day = Bank.find_by(user_id: user.id).balance_furlough
        balance_furlough_day_réel = Furlough.get_balance_current_month(user)
        balance_furlough_reel = (b_furlough_day + balance_furlough_day_réel).round(2)

        analysis << [user.first_name, user.last_name, user.email, days_worked_between_two_date, day_off_consumed.uniq.count, balance_d.to_s, balance_h.to_s, all_day_off_consumed.uniq.count, balance_furlough_reel.round(2).to_s] 
      end
  
      return analysis
    end

    def parsed_date(date_string, default)
        Date.parse(date_string)
    rescue ArgumentError, TypeError
        default
    end  
end