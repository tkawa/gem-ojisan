class ProjectCheckLog < ApplicationRecord
  belongs_to :project, required: true, inverse_of: :project_check_logs
  belongs_to :check_log, required: true, inverse_of: :project_check_logs

  validates :color, :red_count, :dependency_count, presence: true

  def red_rate
    dependency_count == 0 ? 0 : (100.0 * red_count / dependency_count).round
  end

  def self.build_from_audit(audit)
    project_check_log = new(color: audit['vulnerable'] ? 'red' : 'green')
    project_check_log.advisories = audit['advisories']
    project_check_log.red_count = audit['advisories'].count
    project_check_log.dependency_count = audit['advisories'].count
    project_check_log
  end
end
