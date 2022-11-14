class Absence < ApplicationRecord
  belongs_to :user
  belongs_to :absence_type

  scope :filter_by_absence_type_id, -> (type_absences) { where('absences.absence_type_id = ?', type_absences) }
  scope :filter_by_absence_type_ids, -> (type_absences) { where absence_type_id: type_absences }
  scope :filter_by_sup_date, -> (date) { where("absences.start_time > ?", date.to_datetime) }
  scope :filter_by_inf_date, -> (date) { where("absences.start_time < ?", date.to_datetime) }
  scope :filter_by_egal_date, -> (date) { where("absences.start_time like ?", date.to_datetime) }
end


