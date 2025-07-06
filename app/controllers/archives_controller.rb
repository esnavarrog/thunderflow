class ArchivesController < ApplicationController
  before_action :set_archive, only: [:destroy]
  def destroy
    unless @archive.destroy
      return render :delete_error
    end
  end

  private

  def set_archive
    @archive = Archive.find(params[:id])
  end
end
