class AddAdvisoriesToProjectCheckLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :project_check_logs, :advisories, :jsonb
  end
end
