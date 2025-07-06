class ToolsController < ApplicationController

  def index
    authorize :tool
  end
end
