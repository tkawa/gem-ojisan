source 'https://rubygems.org'

ruby '2.5.1'

gem 'rails', '5.2.0'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'pg', '~> 0.15'

# assets
gem 'sassc-rails'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails'

# jquery & turbolinks
gem 'jquery-rails'
gem 'turbolinks'

# models
gem 'enumerize'
gem 'mini_magick'

# views
gem 'haml-rails'
gem 'bootstrap-sass'
gem 'font-awesome-rails'
gem 'simple_form'
gem 'kaminari'

# authentication
gem 'devise'
gem 'omniauth'
gem 'omniauth-google-oauth2'

# network
gem 'faraday'
gem 'faraday_middleware'

# server
gem 'puma'

# memory tuning
gem 'memtuner', github: 'shunichi/memtuner-ruby'

group :development, :test do
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'timecop'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'poltergeist'
  gem 'dotenv-rails'

  gem 'byebug'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'letter_opener_web'
  gem 'bullet'
  gem 'erb2haml'
  gem 'heroku_san'
end

group :production do
  gem 'heroku-deflater'
  gem 'newrelic_rpm'
end

