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

  def self.check
    start_time = Time.now
    Rails.logger.info 'Gemnasium.check start'

    response = RestClient.get gemnasium_api_url('/v1/projects')
    result = JSON.parse(response)

    red_projects = result[api_org_name].each_with_object([]) do |entry, array|
      slug = entry['slug']
      color = entry['color']
      array.push slug if color == 'red'
    end

    red_dependencies = red_projects.each_with_object({}) do |project_name, hash|
      Rails.logger.info "fetching dependencies for #{project_name} ..."
      gem_entries = JSON.parse RestClient.get gemnasium_api_url("/v1/projects/#{project_name}/dependencies")
      # 一度もチェックされていない場合 empty array が返る
      hash[project_name] = gem_entries.select { |entry| entry['color'] == 'red' } if gem_entries.present?
    end

    if red_dependencies.present?
      response = remotty_post_entry build_ranking_message(red_dependencies)
      entry_id = JSON.parse(response)['id']
      remotty_post_entry build_list_message(red_dependencies), entry_id
    end

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
