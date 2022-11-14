module AdditionalHoursHelper
    def check_period_validity(period)

        end_period = period.split(/ - */).last.to_date

        last_day_of_validity = end_period + 30.day

        return last_day_of_validity

    end  
    
    def self.get_period
      first_day_off_prev_week = Date.today.prev_week
      results = {start_date: (first_day_off_prev_week.year.to_s + "-" + first_day_off_prev_week.month.to_s + "-" + first_day_off_prev_week.day.to_s).to_date.strftime('%Y-%m-%d'), end_date: (first_day_off_prev_week.end_of_week.year.to_s + "-" + first_day_off_prev_week.end_of_week.month.to_s + "-" + first_day_off_prev_week.end_of_week.day.to_s).to_date.strftime('%Y-%m-%d')}
  
      return "Période du " + results[:start_date] + " au  " + results[:end_date]
    end

    def self.get_period_without_string
      first_day_off_prev_week = Date.today.prev_week
      results = {start_date: (first_day_off_prev_week.year.to_s + "-" + first_day_off_prev_week.month.to_s + "-" + first_day_off_prev_week.day.to_s).to_date.strftime('%Y-%m-%d'), end_date: (first_day_off_prev_week.year.to_s + "-" + first_day_off_prev_week.month.to_s + "-" + first_day_off_prev_week.end_of_week.day.to_s).to_date.strftime('%Y-%m-%d')}

      return results[:start_date] + " - " + results[:end_date]
    end

    def self.get_days_of_input_form(period)

        start_period = period.split(/ - */).first.to_date
        end_period = period.split(/ - */).last.to_date
  
        off_days = Off.off_between(start_period, end_period)
  
        off_days_not_include_week_day = []
        if !off_days.empty?
          off_days.each do |off|
            off_days_not_include_week_day << (off.start.to_date..off.end.to_date).to_a.select {|k| [1,2,3,4,5,6].include?(k.wday)} 
          end
        end
  
        days_of_input_form = []
        off_days_not_include_week_day.each do |day|
          days_of_input_form += day
        end
        days_of_input_form.push(end_period)
  
        return days_of_input_form 
    end   

    def self.get_offs_of_form
        period = AdditionalHoursHelper.get_period_without_string
        days_of_form = AdditionalHoursHelper.get_days_of_input_form(period)
        days_of_form.pop

        return days_of_form
    end

end