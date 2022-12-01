class User < ApplicationRecord
  require 'csv'

  serialize :manager_titles, Array
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable, and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable, :lockable, :trackable#, :confirmable

  validates :matricule, presence: true
  validates :matricule, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :email, uniqueness: true
  validates :started_at, presence: true
  validates :gender, presence: true
  validates :family_status, presence: true
  validates :job_title, presence: true

  has_many :journals
  has_many :additional_hours
  
  enum status: {
    created: 1,
    actif: 2,
    desabled: 3,
    suspended: 4
  }

  MANAGERS = ["Gestionnaire fonctionnel", "Gestionnaire hiérarchique"]

  has_one_attached :avatar
  has_one_attached :document
  
  belongs_to :role
  has_many :furloughs
  has_one :bank
  has_many :costs

  def self.search(params)  
    p = params[:search]   
    where("first_name LIKE ? OR last_name LIKE ?", "%#{params[:search]}%","%#{params[:search]}%") if params[:search].present? 
  end

  def self.full_name(user_id)
    user=User.find(user_id)
    user.first_name + " " + user.last_name
  end

  def full_name_user
    "#{first_name} #{last_name}"
  end

  def after_confirmation
    self.actif!
    self.is_active = true
    self.save
  end

  def active_for_authentication?
    super and self.is_active?
  end

  scope :users_by_role, ->(role_id) { where('role_id = ?', role_id) }
  scope :get_name_of_line_manager, ->(id) { where('line_manager_id = ?', id) }
  scope :get_name_of_fonctionnal_manager, ->(id) { where('fonctionnal_manager_id = ?', id) }

 
  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
        User.create! row.to_hash
    end
  end

  def self.custom_finder(first_name, last_name, email, started_at)
    user = User.find_by(first_name: first_name, last_name: last_name, email: email, started_at: started_at)
    if user.present?
     return true
    else
      return false
    end
  end

end
