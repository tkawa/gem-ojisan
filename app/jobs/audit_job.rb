class AuditJob < ApplicationJob
  include Rails.application.routes.url_helpers

  def perform(check_log, project)
    url = project_check_log_url(project_id: project.id, id: check_log.id, user: ENV['BASIC_AUTH_USER'], password: ENV['BASIC_AUTH_PASS'])
    build_parameters = {
      CIRCLE_JOB: 'bundle_update',
      PROJECT: project.slug,
      GEM_OJISAN_URL: url
    }

    circle_trigger_url = 'https://circleci.com/api/v1.1/project/github/tkawa/gem-ojisan/tree/self-audit' # FIXME
    conn = Faraday.new(circle_trigger_url) do |b|
      b.request  :url_encoded
      b.basic_auth ENV['CIRCLE_API_USER_TOKEN'], ''
      b.response :json
      b.response :logger
      b.adapter Faraday.default_adapter
    end
    conn.post('', build_parameters: build_parameters)
  end

  private

  def default_url_options
    # {host: 'gem-ojisan-staging.herokuapp.com', protocol: 'https'}
    Rails.application.config.action_mailer.default_url_options
  end
end
