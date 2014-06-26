class StatisticsController < ApplicationController
  before_filter :sign_out_disabled_users
  prepend_before_filter :authenticate_user!
  
  layout :layout_used
  
  def csadp_bd_statistics
  
  end
  
  def lv_statistics
  
  end
  
  def global_demands_sent
    @number_of_demands = global_number_of_demands_and_documents("SELECT * FROM demands WHERE created_at")
  end
  
  def global_demands_rejected
    @number_of_demands = global_number_of_demands_and_documents("SELECT * FROM demands WHERE unavailable_by_at")
  end
  
  def global_demands_validated
    @number_of_demands = global_number_of_demands_and_documents("SELECT * FROM demands WHERE validated_by_at")
  end
  
  def global_number_of_documents_taken
    @number_of_documents = global_number_of_demands_and_documents("SELECT * FROM demands WHERE taken_by_at")
  end
  
  def global_number_of_documents_returned
    @number_of_documents = global_number_of_demands_and_documents("SELECT * FROM demands WHERE returned_by_at")
  end
  
  def global_number_of_documents_damaged
    @number_of_documents = global_number_of_demands_and_documents("SELECT * FROM demands WHERE book_damaged_by_at")
  end  
  
  def personnal_demands_sent
    @number_of_demands = global_number_of_demands_and_documents("SELECT * FROM demands WHERE user_id = #{current_user.id} AND created_at")
  end
  
  def personnal_demands_rejected
    @number_of_demands = global_number_of_demands_and_documents("SELECT * FROM demands WHERE user_id = #{current_user.id} AND unavailable_by_at")
  end
  
  def personnal_demands_validated
    @number_of_demands = global_number_of_demands_and_documents("SELECT * FROM demands WHERE user_id = #{current_user.id} AND validated_by_at")
  end
  
  def personnal_number_of_documents_taken
    @number_of_documents = global_number_of_demands_and_documents("SELECT * FROM demands WHERE user_id = #{current_user.id} AND taken_by_at")
  end
  
  def personnal_number_of_documents_returned
    @number_of_documents = global_number_of_demands_and_documents("SELECT * FROM demands WHERE user_id = #{current_user.id} AND returned_by_at")
  end
  
  def personnal_number_of_documents_damaged
    @number_of_documents = global_number_of_demands_and_documents("SELECT * FROM demands WHERE user_id = #{current_user.id} AND book_damaged_by_at")
  end
  
  def global_number_of_demands_and_documents(sql)
    @number_of_demands = []
    @months = months_between(Date.new(Date.today.year, 1), Date.new(Date.today.year, 12))

  	@months.each do |month|
  		@demands = ActiveRecord::Base.connection.execute("#{sql} BETWEEN '#{month.at_beginning_of_month}' AND '#{month.at_end_of_month}'")
  		@number_of_demands << @demands.count
  	end
  	@number_of_demands
  end
  
end
