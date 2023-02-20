class AbsenceType < ApplicationRecord
    has_many :absences

    validates :code, presence: true, uniqueness: true
    validates :name, presence: true, uniqueness: true

    def destroy_absence_type
        begin
            self.destroy
            result = {flash_type: "success", message: "Absence type was successfully destroyed."}
        rescue Exception 
            result = {flash_type: "danger", message: "Can't delete this absence type!, by what it contains #{self.absences.count} instance of absences"}
        end
    end
end
