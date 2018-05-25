class CheckLog < ApplicationRecord
  has_many :project_check_logs, dependent: :destroy, inverse_of: :check_log

  def ranking(count)
    logs = project_check_logs.includes(:project).order(red_count: :desc)
    logs_by_red_count = logs.group_by { |log| log.red_count }
    rank = 1
    result = []
    logs_by_red_count.keys.sort.reverse.each do |red_count|
      result += logs_by_red_count[red_count].map { |log| [rank, log] }
      rank += logs_by_red_count[red_count].size
      break if rank > count
    end
    result
  end

  def self.start_audit
    check_log = create!
    Project.all.each do |project|
      AuditJob.perform_later(check_log, project)
    end
    ReportJob.perform_later(check_log)
  end
end
