module FurloughsHelper
    def is_max_duration(furlough_id, d1, h1, d2, h2, furlough_type_id)

        duration = 0.0
        Furlough.where(parent_id: furlough_id).each do |f|
          duration += Furlough.get_furlough_duration(f.start, f.hour_start, f.end, f.hour_end)
        end
        duration += Furlough.get_furlough_duration(d1, h1, d2, h2)

       furlough_type = FurloughType.find(furlough_type_id)
       if duration < furlough_type.max_duration
         return false
       else
         return true
       end
    end

    def furlough_du(d1, h1, d2, h2)
        furlough_duration = Furlough.get_furlough_duration(d1, h1, d2, h2)
        return furlough_duration
    end

    def is_max_period(furlough)
        furlough_type = FurloughType.find(furlough.furlough_type_id)
        if Date.current.mjd - furlough.start.to_date.mjd < furlough_type.discontinuity_period
            return false
        else
            return true
        end
    end
end
