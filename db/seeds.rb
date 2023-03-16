#intialisation roles table
['Super Admin', 'Rh', 'Collaborateur'].each do |role|
    Role.find_or_create_by({title: role})
end

[['Heure sup. jours ouvrés - HSJO', 'HSJO'], ['Heure sup. jours fériés travaillés - HSJFT', 'HSJFT']].each do |additional_hour_type|
    AdditionalHourType.find_or_create_by({name: additional_hour_type[0], code: additional_hour_type[1]})
end

Setting.create(month_balance: 1.5, day_work_hour: 8, informing_before_duration: 48, number_items_of_page: 8, cancel_after_duration: 2)

#intialisation users table
default_user = User.create(matricule: "S1", first_name: "admin", last_name: "admin", email: "admin.admin@alithya.com", password: "123456", password_confirmation: "123456", role_id: 1, is_active: true, status: 2,
                           started_at: '2021-08-10', gender: "1", family_status: "Autre", job_title: "Directeur principal", home_adress: "Av mohamed V ...", phone_number: "+2126.......", confirmed_at: DateTime.now, is_started_at_confirmed: true, company_id: 1)

#default_user.avatar.attach(io: File.open(Rails.root.join('app/assets/images/avatar-profile.png')),
                  #filename: 'cat.jpg')
#default_user.send_confirmation_instructions 
Bank.create(user_id: 1, balance_furlough: 0.0, balance_open_additional_hour: 0, balance_open_additional_hour_off_days: 0, company_id: 1)



default_user2 = User.create(matricule: "S2", first_name: "admin", last_name: "admin", email: "admin.admin@vo2group.com", password: "123456", password_confirmation: "123456", role_id: 2, is_active: true, status: 2,
            started_at: '2021-08-10', gender: "1", family_status: "Autre", job_title: "Directeur principal", home_adress: "Av mohamed V ...", phone_number: "+2126.......", confirmed_at: DateTime.now, is_started_at_confirmed: true, company_id: 2)

#default_user2.avatar.attach(io: File.open(Rails.root.join('app/assets/images/avatar-profile.png')),
                           #filename: 'cat.jpg')
#default_user2.send_confirmation_instructions
Bank.create(user_id: 2, balance_furlough: 0.0, balance_open_additional_hour: 0, balance_open_additional_hour_off_days: 0, company_id: 2)