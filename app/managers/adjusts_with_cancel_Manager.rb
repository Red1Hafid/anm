class AdjustsWithCancelManager
    def self.adjust(first_off, adjust_params)
        status = ["Soumis", "Approuvé", "Régularisé"]
        year_off_first_off = first_off.start.year
        next_year = year_off_first_off + 1
        furloughs = Furlough.furloughs_of_adjust(year_off_first_off).where(status: status)
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
            bank = Bank.find_by(user_id: f.user_id)
            balance_user_furlough = bank.balance_furlough
            first_furlough_duration = Furlough.get_furlough_duration(f.start, f.hour_start, f.end, f.hour_end)
            balance = balance_user_furlough + first_furlough_duration
            bank.update(balance_furlough: balance)
            last_furlough_duration = AdjustsManager.get_furlough_duration_of_adjust(f.start, f.hour_start, f.end, f.hour_end, adjust_params)
            balance_user_furlough_adjust = bank.balance_furlough
            balance_adjust = balance_user_furlough_adjust - last_furlough_duration
            bank.update(balance_furlough: balance_adjust)
        end   

        first_off.update(adjust_params)
    end
end