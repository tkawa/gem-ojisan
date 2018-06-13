class AuditJob < ApplicationJob
  def perform(check_log, project)
    env = {'PROJECT' => project.slug}
    system(env, Rails.root.join('bin/review-bundle-update').to_s)
    json_string = `cd /tmp/#{project.slug}_bundle_update && bundle audit -F json` # TODO: improve
    result = JSON.parse(json_string)

    if result['vulnerable']
      project_check_log = ProjectCheckLog.new(project: project, check_log: check_log, color: 'red')
      project_check_log.advisories = results['advisories']
      project_check_log.red_count = results['advisories'].count
      project_check_log.dependency_count = results['advisories'].count
    else
      project_check_log = ProjectCheckLog.new(project: project, check_log: check_log, color: 'green')
      project_check_log.red_count = 0
      project_check_log.dependency_count = 0
    end
    project_check_log.save
  end

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
  #     },
end
