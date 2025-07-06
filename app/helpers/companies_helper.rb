module CompaniesHelper

    def format_rut(rut)
        if rut
            rutArray = rut.split('-')
            rutArray[0] = rutArray[0].to_s.gsub(/\./, "").to_i
            rut = number_with_delimiter(rutArray[0], precision:0, delimiter:'.').to_s + '-' + rutArray[1].to_s
            rut
        end
    end
end
