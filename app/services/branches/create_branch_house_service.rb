
class Branches::CreateBranchHouseService < ApplicationService
    def self.execute(company, params = {})
        # create house matriz
        params_to_create = {
            name: "Casa Matriz",
            phone_number: company.phone_number,
            status: :active,
            email: company.email,
            responsible_name:company.responsible_name,
            latitude:company.latitude,
            longitude:company.longitude,
            city:'Santiago',
            country:'Chile',
            commune:company.commune,
            dpto:company.dpto,
            address_concat: company.address_concat,
            reference: company.reference,
            company_id:company.id,
            time_open:company.time_open,
            time_close:company.time_close
        }
        branch = Branch.create(params_to_create)
        branch
    end
end