class ProjectsController < ApplicationController
  def index
    @projects = Project.order(:slug)
  end

  def show
    @project = Project.find(params[:id])
  end
end
