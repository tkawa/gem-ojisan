namespace :gemnasium do
  desc 'check gemnasium'

  task check: :environment do
    Reporter.check if Date.current.wday == 4 # とりあえず木曜日
  end
end
