namespace :gemnasium do
  desc 'check gemnasium'

  task check: :environment do
    Gemnasium.check if Date.current.wday == 4 # とりあえず木曜日
  end
end
