desc "create admin user for vo2group company"
task create_admin_user: :environment do
  puts 'Start creating user'
  default_user2 = User.create(matricule: "S2", first_name: "admin", last_name: "admin", email: "admin.admin@vo2group.com", password: "123456", password_confirmation: "123456", role_id: 2, is_active: true, status: 2,
                              started_at: '2021-08-10', gender: "1", family_status: "Autre", job_title: "Directeur principal", home_adress: "Av mohamed V ...", phone_number: "+2126.......", confirmed_at: DateTime.now, is_started_at_confirmed: true, company_id: 3)

  #default_user2.avatar.attach(io: File.open(Rails.root.join('app/assets/images/avatar-profile.png')),
  #filename: 'cat.jpg')
  #default_user2.send_confirmation_instructions
  Bank.create(user_id: 3, balance_furlough: 0.0, balance_open_additional_hour: 0, balance_open_additional_hour_off_days: 0, company_id: 3)


  puts 'End'
end
