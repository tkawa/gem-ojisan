class Reporter
  def self.base_url
    ENV['REMOTTY_BASE_URL'] || 'https://www.sonicgarden.world/'
  end

  def self.remotty_group_id
    ENV['REMOTTY_GROUP_ID']
  end

  def self.remotty_token
    ENV['REMOTTY_TOKEN']
  end

  def self.remotty_post_url
    "#{base_url}api/v1/groups/#{remotty_group_id}/entries.json"
  end

  def self.remotty_post_entry(message, parent_id = nil)
    json = {entry: {content: message, parent_id: parent_id}}.to_json
    RestClient.post remotty_post_url, json, content_type: :json, accept: :json, Authorization: "Bearer #{remotty_token}"
  end

  def self.icon_message(message)
    "![](https://pbs.twimg.com/profile_images/425255790320947201/mNYZcFSq_bigger.jpeg) #{message}"
  end

  def self.build_list_message(project_check_logs)
    out = StringIO.new
    project_check_logs = project_check_logs.select { |l| l.color == 'red' }
    out.puts icon_message("#{project_check_logs.size}個のプロジェクトで危険なgemが使われているよ。")
    project_check_logs.each do |project_check_log|
      project_name = project_check_log.project.slug
      out.puts "### [#{project_name}](https://github.com/#{project_name})"
      Array(project_check_log.advisories).each do |advisory|
        package_name = advisory['name']
        version = advisory['version']
        vulnerability = advisory['title']
        url = advisory['url']
        out.puts "- [#{package_name} #{version}: #{vulnerability}](#{url})"
      end
      out.puts
    end
    out.string
  end

  MAX_RANK = 10
  def self.build_ranking_message(project_check_logs)
    out = StringIO.new
    out.puts icon_message('危険なgem数ランキングだよ！')
    entries_by_red_count = project_check_logs.group_by(&:red_count)
    rank = 1
    entries_by_red_count.keys.sort.reverse.each do |red_count|
      entries_by_red_count[red_count].each do |project_check_log|
        project_name = project_check_log.project.slug
        out.puts "- #{rank}位 [#{project_name}](https://github.com/#{project_name}) (#{red_count}個)"
      end
      rank += entries_by_red_count[red_count].size
      break if rank > MAX_RANK
    end
    out.string
  end

  def self.build_stats_message(project_check_logs)
    active_project_count = project_check_logs.size
    inactive_projects = [] # TODO
    red_dependencies, not_red_projects = project_check_logs.partition { |l| l.color == 'red' }
    average_red_deps = active_project_count == 0 ? 0 : project_check_logs.sum { |l| l.advisories.size } / active_project_count.to_f

    out = StringIO.new
    out.puts icon_message('統計情報だよ！')
    out.puts "- プロジェクトが使っている危険なgemの平均数 #{average_red_deps.round(1)}"
    out.puts "- 全プロジェクト数 #{active_project_count + inactive_projects.size}"
    out.puts "- 危険なgemを使っているプロジェクト数 #{red_dependencies.size}"
    out.puts "- 危険なgemを使ってないプロジェクト数 #{not_red_projects.size}"
    # out.puts "- 一度もチェックされてないプロジェクト数 #{inactive_projects.size}"

    out.string
  end

  def self.build_no_red_message
    icon_message("危険なgemを使っているプロジェクトはないよ！\nすごい！おめでとう！")
  end

  # TODO: インスタンス化して使うように
  def initialize
  end
end
