module ApplicationHelper

    def format_date(date = nil)
        date.strftime('%d-%m-%Y') if date
    end

    def format_date_human(date = nil)
        l(date, format:'%a %d de %b, %Y').capitalize if date
    end

    def format_date_time(date = nil)
        date.strftime('%d-%m-%Y %H:%M') if date
    end

    def format_time(date = nil)
        date.strftime('%H:%M') if date
    end

    def format_date_estimated(date = nil)
        date = date+2.days if date
        date.strftime('%d-%m-%Y') if date
    end

    def format_to_hours(seconds = nil)
        return if seconds.nil? || seconds.blank?
        return seconds if seconds.is_a?(DateTime)

        hours = seconds / 3600
        minutes = (seconds % 3600) / 60

        format('%02d:%02d', hours, minutes)
    end
end
