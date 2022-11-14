module AutorizationsHelper
    def is_recovred_by_balance(autorization)
        setting = Setting.find(1)
        bank = Bank.find_by(user_id: autorization.user_id)
        furlough_balance = (bank.balance_furlough * setting.day_work_hour).round(2)
        additional_hours_balance = bank.balance_open_additional_hour_off_days

        balance = 0.0
        
        if furlough_balance > 0
            balance += furlough_balance
        end

        if additional_hours_balance > 0
            balance += additional_hours_balance
        end

        puts "--------balance"
        puts balance

        if balance > 0
          return true
        else
          return false
        end
    end
end
