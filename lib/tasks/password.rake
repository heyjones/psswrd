namespace :password do

  task destroy: :environment do

    @password = Password.where(['created_at < ?', 1.days.ago]).delete_all

  end

end
