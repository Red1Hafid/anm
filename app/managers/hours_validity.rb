class HoursValidity 

    def self.get_valid_hours_2(user_id, d1, h1, d2, h2)
        additional_hour_type_id = AdditionalHourType.find_by(code: "HSJFT").id
        hsjf = AdditionalHour.where(user_id: user_id).where(status: 2, additional_hour_type_id: additional_hour_type_id, is_done: false).order(:period)

        results = {additional_hours: [], consumed_hours: [], stay_hours: []}
        hour_valide_in_period = 0

        furlough_duration = Furlough.get_hour_furlough_duration(d1, h1, d2, h2)
       
        hsjf.each do |additional_hour_off|
            end_period = additional_hour_off.period.split(/ - */).last.to_date
            last_day_of_validity = end_period + 30.day

            results[:additional_hours].push(additional_hour_off.id) 
            
            if (d1 < last_day_of_validity && d2 <= last_day_of_validity) || (d1 < last_day_of_validity && d2 >= last_day_of_validity)
            
                if d2 < last_day_of_validity && d1 < last_day_of_validity 
                    hour_valide_in_period += additional_hour_off.stay_hours
                    if hour_valide_in_period > furlough_duration
                        results[:consumed_hours].push(additional_hour_off.stay_hours - (hour_valide_in_period - furlough_duration)) 
                        results[:stay_hours].push(additional_hour_off.stay_hours - (hour_valide_in_period - furlough_duration))
                        hour_valide_in_period -= (hour_valide_in_period - furlough_duration)
                        
                    else
                        results[:consumed_hours].push(additional_hour_off.stay_hours) 
                        results[:stay_hours].push(additional_hour_off.stay_hours)
                    end
                else
                    duration = Furlough.get_hour_furlough_duration(d1, h1, last_day_of_validity, '8:00')
                    
                    if duration <= additional_hour_off.stay_hours
                        hour_valide_in_period += duration
                        results[:consumed_hours].push(duration) 
                        results[:stay_hours].push(duration)
                    else
                        hour_valide_in_period += additional_hour_off.stay_hours
                        if hour_valide_in_period > furlough_duration
                            results[:consumed_hours].push(additional_hour_off.stay_hours - (hour_valide_in_period - furlough_duration)) 
                            results[:stay_hours].push(additional_hour_off.stay_hours - (hour_valide_in_period - furlough_duration))
                            hour_valide_in_period -= (hour_valide_in_period - furlough_duration)
                        else
                            results[:consumed_hours].push(additional_hour_off.stay_hours) 
                            results[:stay_hours].push(additional_hour_off.stay_hours)
                        end
                        
                    end
                end
            else
                hour_valide_in_period += 0
                results[:consumed_hours].push(0) 
                results[:stay_hours].push(0)
            end
                  
        end

        results[:hour_valide_in_period] = hour_valide_in_period

        puts results

        return results
 
    end
end