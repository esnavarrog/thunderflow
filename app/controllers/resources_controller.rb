class ResourcesController < ApplicationController
    before_action :set_company, only:[:create, :new, :update]
    before_action :set_resource, only:[:update, :edit, :destroy]

    def index

    end

    def new
        @resource = Resource.new
    end

    def create
        @resource = Resource.new(params_resource)
        @resource.company = @company
        if @resource.save
        else
            render :form_error
        end
    end

    def edit
        @company = @resource.company
    end

    def update
        unless @resource.update(params_resource)
            render :form_error
        end
    end

    def destroy
        authorize @resource
        @resource.destroy
    end

    private

    def set_company
        @company = Company.find(params[:company_id])
    end

    def set_resource
        @resource = Resource.find(params[:id])
    end

    def params_resource
        params.require(:resource).permit(
            :name,
            :web_address,
            :branch_id,
            :status
        )
    end
end
