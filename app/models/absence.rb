class Absence < ApplicationRecord
  acts_as_tenant :company
  belongs_to :user
  belongs_to :absence_type

  validates :start_time, presence: true
  validates :end_time, presence: true

  scope :filter_by_absence_type_id, -> (type_absences) { where('absences.absence_type_id = ?', type_absences) }
  scope :filter_by_absence_type_ids, -> (type_absences) { where absence_type_id: type_absences }
  scope :filter_by_sup_date, -> (date) { where("absences.start_time > ?", date.to_datetime) }
  scope :filter_by_inf_date, -> (date) { where("absences.start_time < ?", date.to_datetime) }
  scope :filter_by_egal_date, -> (date) { where("absences.start_time like ?", date.to_datetime) }

  def self.exported_data_filtred(absences, params)
    if params[:date_absence].present?
      if params[:opperateur_date].present?
        case params[:opperateur_date]
        when 'Supérieure que'
          absences = absences.filter_by_sup_date(params[:date_absence]) 
        when 'Inférieure que'
          absences = absences.filter_by_inf_date(params[:date_absence]) 
        when 'Égale'
          absences = absences.filter_by_egal_date(params[:date_absence]) 
        end
      end
    end

    if params[:type_absences].present?
      case params[:type_absences]
      when "Tous"
        absence_types = AbsenceType.where(code: ['ABSJ','ABSI', 'ABST'])
        absences = absences.filter_by_absence_type_ids(absence_types) 
      when 'Absence Justifiée'
        absence_type = AbsenceType.find_by(code: 'ABSJ')
        absences = absences.filter_by_absence_type_id(absence_type) 
      when 'Absence Injustifiée'
        absence_type = AbsenceType.find_by(code: 'ABSI')
        absences = absences.filter_by_absence_type_id(absence_type) 
      when 'Accident de travail'
        absence_type = AbsenceType.find_by(code: 'ABST')
        absences = absences.filter_by_absence_type_id(absence_type) 
      end
    end
  end
end


