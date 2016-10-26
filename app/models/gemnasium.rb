class Gemnasium
  def self.api_key
    ENV['GEMNASIUM_API_KEY']
  end

  def self.api_org_name
    ENV['GEMNASIUM_ORG_NAME']
  end

  def self.gemnasium_api_url(path)
    File.join("https://X:#{api_key}@api.gemnasium.com", path)
  end

  def self.remotty_group_id
    ENV['REMOTTY_GROUP_ID']
  end

  def self.remotty_token
    ENV['REMOTTY_TOKEN']
  end

  def self.remotty_post_url
    "https://www.remotty.net/api/v1/groups/#{remotty_group_id}/entries.json"
  end

  def self.remotty_post_entry(message, parent_id = nil)
    json = {entry: {content: message, parent_id: parent_id}}.to_json
    RestClient.post remotty_post_url, json, content_type: :json, accept: :json, Authorization: "Bearer #{remotty_token}"
  end

  def self.icon_message(message)
    "![](https://pbs.twimg.com/profile_images/425255790320947201/mNYZcFSq_bigger.jpeg) #{message}"
  end

  def self.build_list_message(red_dependencies)
    out = StringIO.new
    out.puts icon_message("#{red_dependencies.size}個のプロジェクトで危険なgemが使われているよ。")
    red_dependencies.each do |project_name, deps|
      out.puts "### [#{project_name}](https://gemnasium.com/github.com/#{project_name})"
      deps.each do |dep|
        package = dep['package']
        package_name = package['name'] if package
        dist = package['distributions'] if package
        stable = "(latest: #{dist['stable']})" if dist['stable']
        version = dep['locked']
        gem_url = "https://gemnasium.com/gems/#{package_name}/versions/#{version}"
        out.puts "- [#{package_name}: #{version} #{stable}](#{gem_url})"
      end
      out.puts
    end
    out.string
  end

  MAX_RANK = 10
  def self.build_ranking_message(red_dependencies)
    out = StringIO.new
    out.puts icon_message('危険なgem数ランキングだよ！')
    entries_by_red_count = red_dependencies.group_by { |entry| entry.second.size }
    rank = 1
    entries_by_red_count.keys.sort.reverse.each do |red_count|
      entries_by_red_count[red_count].each do |entry|
        project_name = entry.first
        out.puts "- #{rank}位 [#{project_name}](https://gemnasium.com/github.com/#{project_name}) (#{red_count}個)"
      end
      rank += entries_by_red_count[red_count].size
      break if rank > MAX_RANK
    end
    out.string
  end

  def self.build_stats_message(red_dependencies, not_red_projects, inactive_projects)
    active_project_count = red_dependencies.size + not_red_projects.size
    average_red_deps = active_project_count == 0 ? 0 : red_dependencies.values.map(&:size).sum / active_project_count.to_f

    out = StringIO.new
    out.puts icon_message('統計情報だよ！')
    out.puts "- プロジェクトが使っている危険なgemの平均数 #{average_red_deps.round(1)}"
    out.puts "- 全プロジェクト数 #{active_project_count + inactive_projects.size}"
    out.puts "- 危険なgemを使っているプロジェクト数 #{red_dependencies.size}"
    out.puts "- 危険なgemを使ってないプロジェクト数 #{not_red_projects.size}"
    out.puts "- 一度もチェックされてないプロジェクト数 #{inactive_projects.size}"

    out.string
  end

  def self.build_no_red_message
    icon_message("危険なgemを使っているプロジェクトはないよ！\nすごい！おめでとう！")
  end

  def initialize
    response = RestClient.get self.class.gemnasium_api_url('/v1/projects')
    json = JSON.parse(response)
    build_project_check_logs(json)
    build_dependencies
    post_to_remotty
  end

  def build_project_check_logs(json)
    @check_log = CheckLog.new
    @projects = {}
    @project_check_logs = {}
    json[self.class.api_org_name].each do |entry|
      slug = entry['slug']
      color = entry['color']

      project = Project.find_or_initialize_by(slug: slug)
      @projects[slug] = project

      project_check_log = ProjectCheckLog.new(project: project, color: color)
      @check_log.project_check_logs << project_check_log
      @project_check_logs[slug] = project_check_log
    end
  end

  def build_dependencies
    @red_dependencies = {}
    @inactive_projects = []
    @projects.keys.each do |slug|
      project_check_log = @project_check_logs[slug]
      Rails.logger.info "fetching dependencies for #{slug} ..."
      gem_entries = JSON.parse RestClient.get self.class.gemnasium_api_url("/v1/projects/#{slug}/dependencies")
      # 一度もチェックされていない場合 empty array が返る
      if gem_entries.present?
        red_deps = gem_entries.select { |entry| entry['color'] == 'red' }
        @red_dependencies[slug] = red_deps unless red_deps.empty?
        project_check_log.red_count = red_deps.count
        project_check_log.dependency_count = gem_entries.count
      else
        @inactive_projects.push slug
        project_check_log.red_count = 0
        project_check_log.dependency_count = 0
      end
    end
  end

  def post_to_remotty
    if @red_dependencies.present?
      response = self.class.remotty_post_entry self.class.build_ranking_message(@red_dependencies)
      @check_log.remotty_entry_id = JSON.parse(response)['id']

      not_red_projects = @project_check_logs.values.select { |pcl| pcl.color != 'red' }.map { |pcl| pcl.project.slug }
      not_red_projects -= @inactive_projects
      response = self.class.remotty_post_entry self.class.build_stats_message(@red_dependencies, not_red_projects, @inactive_projects), @check_log.remotty_entry_id
      @check_log.remotty_stats_entry_id = JSON.parse(response)['id']

      response = self.class.remotty_post_entry self.class.build_list_message(@red_dependencies), @check_log.remotty_entry_id
      @check_log.remotty_gems_entry_id = JSON.parse(response)['id']
    else
      response = self.class.remotty_post_entry self.class.build_no_red_message
      @check_log.remotty_entry_id = JSON.parse(response)['id']
    end
  end

  def save!
    @check_log.save!
  end

  def self.check
    start_time = Time.now
    Rails.logger.info 'Gemnasium.check start'
    checker = Gemnasium.new
    checker.save!
    Rails.logger.info "Gemnasium.check end (#{(Time.now - start_time).to_i}sec)"
  end

  # https://api.gemnasium.com/v1/projects
  # {
  #   "ORGANIZATION NAME": [
  #     {
  #       "color": "yellow",
  #       "commit_sha": "",
  #       "description": "",
  #       "monitored": true,
  #       "name": "aegis",
  #       "origin": "github",
  #       "private": true,
  #       "slug": "PROJECT NAME",
  #       "unmonitored_reason": ""
  #     },
  #

  # https://api.gemnasium.com/v1/projects/YOUR_PROJECT_NAME/dependencies
  # [
  #   {
  #     "color": "yellow",
  #     "first_level": true,
  #     "id": 163316966,
  #     "locked": "4.5.0",
  #     "package": {
  #       "distributions": {
  #         "prerelease": "4.0.0.rc1",
  #         "stable": "4.7.0"
  #       },
  #       "name": "factory_girl_rails",
  #       "slug": "gems/factory_girl_rails",
  #       "type": "Rubygem"
  #     },
  #     "requirement": ">= 0",
  #     "type": "development"
  #   }
end
