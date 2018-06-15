class ProjectCheckLogsController < ApplicationController
  # wrap_parameters :audit
  skip_forgery_protection
  def create
    project = Project.find(params[:id])
    check_log = CheckLog.find(params[:check_log_id])
    project_check_log = ProjectCheckLog.build_from_audit(audit)
    project_check_log.project = project
    project_check_log.check_log = check_log
    if project_check_log.save
      head :ok
    else
      render json: project_check_log.errors.to_hash, status: :unprocessable_entity
    end
  end

  private

  def audit
    params.slice(:vulnerable, :insecure_sources, :advisories).to_unsafe_h
  end
end
