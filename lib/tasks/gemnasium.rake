namespace :gemnasium do
  desc 'check gemnasium'

  task check: :environment do
    Gemnasium.check
  end
end
