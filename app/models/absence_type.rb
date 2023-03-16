class AbsenceType < ApplicationRecord
    acts_as_tenant :company
    has_many :absences

    validates :code, presence: true, uniqueness: true
    validates :name, presence: true, uniqueness: true

    def destroy_absence_type
        begin
            self.destroy
            result = {flash_type: "success", message: "Le type d'absence a été supprimer avec succès."}
        rescue Exception 
            result = {flash_type: "danger", message: "Impossible de supprimer ce type d'absence !, il contient #{self.absences.count} lignes d'absences"}
        end
    end
end
