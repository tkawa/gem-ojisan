class ProjectCheckLogsController < ApplicationController
  # wrap_parameters :audit
  skip_forgery_protection

  # bundler-audit JSON
  # {
  #   "vulnerable": true,
  #   "insecure_sources": [
  #
  #   ],
  #   "advisories": [
  #     {
  #       "name": "loofah",
  #       "version": "2.1.1",
  #       "advisory": "CVE-2018-8048",
  #       "criticality": "Unknown",
  #       "url": "https://github.com/flavorjones/loofah/issues/144",
  #       "description": "Loofah allows non-whitelisted attributes to be present in sanitized\noutput when input with specially-crafted HTML fragments.\n",
  #       "title": "Loofah XSS Vulnerability",
  #       "solution": "upgrade to >= 2.2.1"
  #     }, …
  def create
    project = Project.find(params[:project_id])
    check_log = CheckLog.find(params[:id])
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
