namespace :samples do
  task users: :environment do
    User.find_or_create_by(email: 'swfeiyang@gmail.com') do |user|
      user.password = 'mars1234'
      user.confirmed_at = Time.now

      user.access_key = 'vqgdf4gsga-aed5e526-7efce3b7-60407'
      user.secret_key = '38939ebe-6a886198-cecaa157-43fea'
    end
    puts 'finished create users'
  end
end