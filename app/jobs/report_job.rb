class ReportJob < ApplicationJob
  def perform(check_log)
    project_check_logs = check_log.project_check_logs.to_a
    if project_check_logs.present?
      response = Reporter.remotty_post_entry(Reporter.build_ranking_message(project_check_logs))
      check_log.remotty_entry_id = JSON.parse(response)['id']

      response = Reporter.remotty_post_entry(Reporter.build_stats_message(project_check_logs), check_log.remotty_entry_id)
      check_log.remotty_stats_entry_id = JSON.parse(response)['id']

      response = Reporter.remotty_post_entry(Reporter.build_list_message(project_check_logs), check_log.remotty_entry_id)
      check_log.remotty_gems_entry_id = JSON.parse(response)['id']
    else
      response = Reporter.remotty_post_entry(Reporter.build_no_red_message)
      check_log.remotty_entry_id = JSON.parse(response)['id']
    end
    check_log.save!
  end
end
