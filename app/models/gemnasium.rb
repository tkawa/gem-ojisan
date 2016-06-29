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

  def self.remotty_post_entry(message)
    json = {entry: {content: message}}.to_json
    RestClient.post remotty_post_url, json, content_type: :json, accept: :json, Authorization: "Bearer #{remotty_token}"
  end

  def self.build_message(red_dependencies)
    out = StringIO.new
    out.puts '![](https://pbs.twimg.com/profile_images/425255790320947201/mNYZcFSq_bigger.jpeg) ヤバい gem が使われてるぞー！'
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

    red_dependencies = red_projects.take(2).each_with_object({}) do |project_name, hash|
      Rails.logger.info "fetching dependencies for #{project_name} ..."
      gem_entries = JSON.parse RestClient.get gemnasium_api_url("/v1/projects/#{project_name}/dependencies")
      # 一度もチェックされていない場合 empty array が返る
      hash[project_name] = gem_entries.select { |entry| entry['color'] == 'red' } if gem_entries.present?
    end

    if red_dependencies.present?
      remotty_post_entry build_message(red_dependencies)
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
