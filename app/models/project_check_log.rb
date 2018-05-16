class ProjectCheckLog < ApplicationRecord
  belongs_to :project, required: true, inverse_of: :project_check_logs
  belongs_to :check_log, required: true, inverse_of: :project_check_logs

  validates :color, :red_count, :dependency_count, presence: true

  def red_rate
    dependency_count == 0 ? 0 : (100.0 * red_count / dependency_count).round
  end
end
