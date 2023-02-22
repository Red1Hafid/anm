class Off < ApplicationRecord
    validates :description, uniqueness: true
    validates :description, presence: true
    validates :title, uniqueness: true
    validates :title, presence: true

    acts_as_tenant :company

    scope :off_between, lambda {|start_date, end_date| where("offs.start <= ? AND offs.end >= ?", end_date, start_date )}
    scope :year, lambda{|year| where("EXTRACT(YEAR FROM start) = ? ", year ) if year.present? }
    scope :all_year, -> { where("EXTRACT(YEAR FROM start)") }
    scope :offs_by_year, lambda{|year| where('EXTRACT(YEAR from offs.start) = ?', year)}

    def self.import(file)
        @errors = []
        successes = []

        CSV.foreach(file.path, headers: true) do |row|
            hash = row.to_hash

            off_to_create = Off.new(
                title: hash['Jour férié'],
                start: hash['Date de début'],
                end: hash['Date de fin'],
                description: hash['Description']
            )

            status_date = "success"
            if off_to_create.start > off_to_create.end
                status_date = "failed"
            end

            if off_to_create.valid?
                if status_date == "success"
                    off_to_create.save
                    successes.push(:ligne => hash['Ligne'], :message => "Cette ligne à été bien inséré en base de données")
                else
                    @errors.push(:ligne => hash['Ligne'], :message => "La date de début du jour férié ne dois pas être supérieure de la date de fin du jour férié.")
                end    
            else
                @errors.push(:ligne => hash['Ligne'], :message => off_to_create.errors.objects.each { |e| e.full_message })
            end
        end

        CSV.open("successes_config-jour-fériés" + ".csv", 'wb') do |csv|
            successes.map { |l|
                csv << [l[:ligne], l[:message], 'success']
            }
        end
    
        CSV.open("failures_config-jour-fériés" + ".csv", 'wb') do |csv|
            @errors.map { |l|
                csv << [l[:ligne], l[:message]]
            }
        end
    end

    def self.search(params)     
        where("title LIKE ?", "%#{params[:search]}%") if params[:search].present? 
    end

    def self.is_off(date) 
       is_off = false    
       Off.where("offs.start <= ? AND offs.end >= ?", date, date).each do |o|
            off_result_week_day = (o.start.to_date..o.end.to_date).to_a.select {|k| [1,2,3,4,5].include?(k.wday)}
            if off_result_week_day.include? date.to_date
                is_off = true
            end
       end
       return is_off
    end

    def self.is_off_adjust(date, adjust_param) 
        is_off = false    
       # Off.where("offs.start <= ? AND offs.end >= ?", date, date).each do |o|
             off_result_week_day = (adjust_param[:start].to_date..adjust_param[:end].to_date).to_a.select {|k| [1,2,3,4,5].include?(k.wday)}
             if off_result_week_day.include? date.to_date
                 is_off = true
             end
       # end
        return is_off
    end

    def self.custom_finder(title)
        off = Off.find_by(title: title)
        if off.present?
            return true
        else
            return false
        end
    end
    
end
