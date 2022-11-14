class AdjustsManager
    def self.adjust(first_off, adjust_params)
        status = ["Soumis", "Approuvé", "Régularisé"]
        furloughs = Furlough.where(status: status)
        furloughs_with_off = []
        furloughs.each do |f|
            result_week_day = (f.start.to_date..f.end.to_date).to_a.select {|k| [1,2,3,4,5].include?(k.wday)}
            first_off_result_week_day = (first_off.start.to_date..first_off.end.to_date).to_a.select {|k| [1,2,3,4,5].include?(k.wday)}
            off_result_week_day = (adjust_params[:start].to_date..adjust_params[:end].to_date).to_a.select {|k| [1,2,3,4,5].include?(k.wday)}

            furloughs_including_off_with_first_off = []
            array_to_check_with_first_off = result_week_day & first_off_result_week_day
            if array_to_check_with_first_off.count > 0
                furloughs_including_off_with_first_off.push(f)
            end

            furloughs_including_off_with_adjust_params = []
            array_to_check_with_adjust_params = result_week_day & off_result_week_day
            if array_to_check_with_adjust_params.count > 0
                furloughs_including_off_with_adjust_params.push(f)
            end

            if furloughs_including_off_with_first_off.count > 0 && furloughs_including_off_with_adjust_params.count > 0
                furloughs_with_off += furloughs_including_off_with_adjust_params
            end

            if furloughs_including_off_with_first_off.count > 0 && furloughs_including_off_with_adjust_params.count == 0
                furloughs_with_off += furloughs_including_off_with_first_off
            end

            if furloughs_including_off_with_first_off.count == 0 && furloughs_including_off_with_adjust_params.count > 0
                furloughs_with_off += furloughs_including_off_with_adjust_params
            end
        end

        furloughs_with_off.each do |f|
            first_furlough_duration = Furlough.get_furlough_duration(f.start, f.hour_start, f.end, f.hour_end)
            last_furlough_duration = get_furlough_duration_of_adjust(f.start, f.hour_start, f.end, f.hour_end, adjust_params)
            bank = Bank.find_by(user_id: f.user_id)
            balance_user_furlough = bank.balance_furlough

            if first_furlough_duration == last_furlough_duration
                balance_user =  balance_user_furlough
            elsif first_furlough_duration > last_furlough_duration
                balance_to_add = first_furlough_duration - last_furlough_duration  
                balance_user = balance_user_furlough + balance_to_add               
            else
                balance_to_minus = last_furlough_duration - first_furlough_duration
                balance_user = balance_user_furlough - balance_to_minus
            end  

            bank.update(balance_furlough: balance_user)
        end   

        first_off.update(adjust_params)
    end

    def self.get_furlough_duration_of_adjust(d1, h1, d2, h2, last_off_params)       
        count_furlough = 0.0
        count_day_off = 0.0
        day_off_duration = ((last_off_params[:end].to_date - last_off_params[:start].to_date) / 3600 / 24) + 1

        if day_off_duration == 1
            count_day_off += 1
        else
            off_day_not_include_week_day = (last_off_params[:start].to_date..last_off_params[:end].to_date).to_a.select {|k| [1,2,3,4,5].include?(k.wday)}
            array = off_day_not_include_week_day.select {|o| o <= d2 && o >= d1 }
            count_day_off += array.count
        end

        result_week_day = (d1.to_date..d2.to_date).to_a.select {|k| [1,2,3,4,5].include?(k.wday)}

        if h1 == "8:00" && h2 == "8:00"
            if (Furlough.is_week_day(d1) == true || Off.is_off_adjust(d1, last_off_params) == true) && (Furlough.is_week_day(d2) == true || Off.is_off_adjust(d2, last_off_params) == true)
                count_furlough = ((((result_week_day.count - count_day_off) * 24)) / 24).to_f
            elsif (Furlough.is_week_day(d1) == false || Off.is_off_adjust(d1, last_off_params) == false)  && (Furlough.is_week_day(d2) == true || Off.is_off_adjust(d2, last_off_params) == true)
                count_furlough = ((((result_week_day.count - count_day_off) * 24)) / 24).to_f
            elsif (Furlough.is_week_day(d1) == true || Off.is_off_adjust(d1, last_off_params) == true)  && (Furlough.is_week_day(d2) == false || Off.is_off_adjust(d2, last_off_params) == false)
                count_furlough = ((((result_week_day.count - count_day_off) * 24) - 24) / 24).to_f
            elsif (Furlough.is_week_day(d1) == false || Off.is_off_adjust(d1, last_off_params) == false)  && (Furlough.is_week_day(d2) == false || Off.is_off_adjust(d2, last_off_params) == false)
                count_furlough = ((((result_week_day.count - count_day_off) * 24) - 24) / 24).to_f
            end
        end 

        if h1 == "14:00" && h2 == "8:00"
            if (Furlough.is_week_day(d1) == true || Off.is_off_adjust(d1, last_off_params) == true) && (Furlough.is_week_day(d2) == true || Off.is_off_adjust(d2, last_off_params) == true)
                count_furlough = ((((result_week_day.count - count_day_off) * 24)) / 24).to_f
            elsif (Furlough.is_week_day(d1) == false || Off.is_off_adjust(d1, last_off_params) == false)  && (Furlough.is_week_day(d2) == true || Off.is_off_adjust(d2, last_off_params) == true)
                count_furlough = ((((result_week_day.count - count_day_off) * 24) - 12) / 24).to_f
            elsif (Furlough.is_week_day(d1) == true || Off.is_off_adjust(d1, last_off_params) == true)  && (Furlough.is_week_day(d2) == false || Off.is_off_adjust(d2, last_off_params) == false)
                count_furlough = ((((result_week_day.count - count_day_off) * 24) - 24) / 24).to_f
            elsif (Furlough.is_week_day(d1) == false || Off.is_off_adjust(d1, last_off_params) == false)  && (Furlough.is_week_day(d2) == false || Off.is_off_adjust(d2, last_off_params) == false)
                count_furlough = ((((result_week_day.count - count_day_off) * 24) - 36) / 24).to_f
            end
        end 

        if h1 == "8:00" && h2 == "14:00" 
            if (Furlough.is_week_day(d1) == true || Off.is_off_adjust(d1, last_off_params) == true) && (Furlough.is_week_day(d2) == true || Off.is_off_adjust(d2, last_off_params) == true)
                count_furlough = ((((result_week_day.count - count_day_off) * 24)) / 24).to_f
            elsif (Furlough.is_week_day(d1) == false || Off.is_off_adjust(d1, last_off_params) == false)  && (Furlough.is_week_day(d2) == true || Off.is_off_adjust(d2, last_off_params) == true)
                count_furlough = ((((result_week_day.count - count_day_off) * 24)) / 24).to_f
            elsif (Furlough.is_week_day(d1) == true || Off.is_off_adjust(d1, last_off_params) == true)  && (Furlough.is_week_day(d2) == false || Off.is_off_adjust(d2, last_off_params) == false)
                count_furlough = ((((result_week_day.count - count_day_off) * 24) - 12) / 24).to_f
            elsif (Furlough.is_week_day(d1) == false || Off.is_off_adjust(d1, last_off_params) == false)  && (Furlough.is_week_day(d2) == false || Off.is_off_adjust(d2, last_off_params) == false)
                count_furlough = ((((result_week_day.count - count_day_off) * 24) - 12) / 24).to_f
            end
        end

        if h1 == "14:00" && h2 == "14:00"
            if (Furlough.is_week_day(d1) == true || Off.is_off_adjust(d1, last_off_params) == true) && (Furlough.is_week_day(d2) == true || Off.is_off_adjust(d2, last_off_params) == true)
                count_furlough = ((((result_week_day.count - count_day_off) * 24)) / 24).to_f
            elsif (Furlough.is_week_day(d1) == false || Off.is_off_adjust(d1, last_off_params) == false)  && (Furlough.is_week_day(d2) == true || Off.is_off_adjust(d2, last_off_params) == true)
                count_furlough = ((((result_week_day.count - count_day_off) * 24) - 12) / 24).to_f
            elsif (Furlough.is_week_day(d1) == true || Off.is_off_adjust(d1, last_off_params) == true)  && (Furlough.is_week_day(d2) == false || Off.is_off_adjust(d2, last_off_params) == false)
                count_furlough = ((((result_week_day.count - count_day_off) * 24) - 12) / 24).to_f
            elsif (Furlough.is_week_day(d1) == false || Off.is_off_adjust(d1, last_off_params) == false)  && (Furlough.is_week_day(d2) == false || Off.is_off_adjust(d2, last_off_params) == false)
                count_furlough = ((((result_week_day.count - count_day_off) * 24) - 24) / 24).to_f
            end
        end
   
        return count_furlough
    end
end