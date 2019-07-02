namespace :samples do
  task all: :environment do
    # for init create
    Rake::Task['samples:users'].invoke
  end
end