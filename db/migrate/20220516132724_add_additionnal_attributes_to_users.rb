class AddAdditionnalAttributesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :personnal_email,:string 
    add_column :users, :phone_number,:string 
    add_column :users, :phone_number_fix,:string 
    add_column :users, :job_title,:string
    add_column :users, :gender,:string
    add_column :users, :family_status,:string
    add_column :users, :area_code,:string 
    add_column :users, :home_adress,:string 
    add_column :users, :started_at,:date
  end
end
