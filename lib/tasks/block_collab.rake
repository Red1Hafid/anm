require 'date'

desc "Block collab"
task block_collab: :environment do
    puts 'Start traitement'
        users = User.where(is_active: true)
        f_types_ids = FurloughType.where(is_payer: false).pluck(:id)
        users.each do |user|
            furloughs = Furlough.where(user_id: user.id, status: "Approuvé", furlough_type_id: f_types_ids)
            furloughs.each do |f|
                f_type = FurloughType.find(f.furlough_type_id)
                if (Date.current.mjd - f.start.to_date.mjd) >= f_type.nbr_days_block

                    puts Date.current.mjd - f.start.to_date.mjd
                    user.is_active = false 
                    user.desabled!
                    user.save
                end

                puts Date.current.mjd - f.start.to_date.mjd
            end
        end   
    puts 'End traitement'
end
