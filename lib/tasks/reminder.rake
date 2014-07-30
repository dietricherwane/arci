namespace :reminder do
  	desc "Send email reminder to those who took a document for more than 5 days"
    task :send_after_five_days => :environment do
      @demands = ActiveRecord::Base.connection.execute("SELECT * FROM demands WHERE taken IS TRUE AND returned IS NULL AND book_damaged IS NULL AND taken_by_at < '#{DateTime.now - 5.days}'")
      unless @demands.count == 0
        @user_ids = @demands.map{ |demand| demand["user_id"] }
        @user_ids = @user_ids.uniq
        @user_ids.each do |user_id|
          @user = User.find_by_id(user_id)
          Notifier.send_reminder(@user).deliver
          if (ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?)
            ActiveRecord::Base.connection.close
          end
        end
      end
    end
end
