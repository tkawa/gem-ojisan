namespace :gemnasium do
  desc 'check gemnasium'

  task check: :environment do
    Gemnasium.check if Date.current.wday == 3 # とりあえず水曜日
  end
end
