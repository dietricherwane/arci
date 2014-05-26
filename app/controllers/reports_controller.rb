class ReportsController < ApplicationController
  
  before_filter :sign_out_disabled_users
  prepend_before_filter :authenticate_user!
  
  layout :layout_used
  
  def global_reports
    @on_hold_demands = ActiveRecord::Base.connection.execute("SELECT * FROM demands WHERE on_hold IS TRUE")
    @on_hold_demands_users = ActiveRecord::Base.connection.execute("SELECT DISTINCT user_id FROM demands WHERE on_hold IS TRUE")
    @on_hold_books = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE on_hold IS TRUE")
    
    @validated_demands = ActiveRecord::Base.connection.execute("SELECT * FROM demands WHERE ((validated IS FALSE  AND unavailable IS TRUE) OR validated IS FALSE) AND book_left IS NOT TRUE")
    @validated_demands_users = ActiveRecord::Base.connection.execute("SELECT DISTINCT user_id FROM demands WHERE ((validated IS FALSE  AND unavailable IS TRUE) OR validated IS FALSE) AND book_left IS NOT TRUE")
    @validated_books = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE validated IS FALSE AND book_left IS NOT TRUE AND unavailable IS NOT TRUE")
  
    @documents_to_get_back =  ActiveRecord::Base.connection.execute("SELECT * FROM demands WHERE validated IS TRUE AND taken IS NOT TRUE")
    @documents_to_get_back_users = ActiveRecord::Base.connection.execute("SELECT DISTINCT user_id FROM demands WHERE validated IS TRUE AND taken IS NOT TRUE")
    @books_to_get_back = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE validated IS TRUE AND taken IS NOT TRUE")
  
    @document_to_bring_back = ActiveRecord::Base.connection.execute("SELECT * FROM demands WHERE taken IS TRUE AND returned IS NULL AND book_damaged IS NULL")
    @document_to_bring_back_users = ActiveRecord::Base.connection.execute("SELECT DISTINCT user_id FROM demands WHERE taken IS TRUE AND returned IS NULL AND book_damaged IS NULL")
    @books_to_bring_back = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE taken IS TRUE AND returned IS NULL AND book_damaged IS NULL")
  
    @document_brought_back = ActiveRecord::Base.connection.execute("SELECT * FROM demands WHERE returned = TRUE")
    @document_brought_back_users = ActiveRecord::Base.connection.execute("SELECT DISTINCT user_id FROM demands WHERE returned = TRUE")
    @books_brought_back = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE returned = TRUE")
  end
  
  def personnal_reports
    @on_hold_demands = ActiveRecord::Base.connection.execute("SELECT * FROM demands WHERE on_hold IS TRUE AND user_id = #{current_user.id}")
    @demands = @on_hold_demands.map { |d| d["id"].to_i }
    @demands = @demands.to_s.sub("[", "(").sub("]", ")")
    @demands.eql?("()") ? @demands_sql = "" : @demands_sql = "AND demand_id IN #{@demands}"
    @on_hold_demands_users = ActiveRecord::Base.connection.execute("SELECT DISTINCT user_id FROM demands WHERE on_hold IS TRUE AND user_id = #{current_user.id}")
    @on_hold_books = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE on_hold IS TRUE #{@demands_sql}")
    
    @validated_demands = ActiveRecord::Base.connection.execute("SELECT * FROM demands WHERE ((validated IS FALSE  AND unavailable IS TRUE) OR validated IS FALSE) AND book_left IS NOT TRUE AND user_id = #{current_user.id}")
    @demands = @validated_demands.map { |d| d["id"].to_i }
    @demands = @demands.to_s.sub("[", "(").sub("]", ")")
    @demands.eql?("()") ? @demands_sql = "" : @demands_sql = "AND demand_id IN #{@demands}"
    @validated_demands_users = ActiveRecord::Base.connection.execute("SELECT DISTINCT user_id FROM demands WHERE ((validated IS FALSE  AND unavailable IS TRUE) OR validated IS FALSE) AND book_left IS NOT TRUE AND user_id = #{current_user.id}")
    @validated_books = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE validated IS FALSE AND book_left IS NOT TRUE AND unavailable IS NOT TRUE #{@demands_sql}")
  
    @documents_to_get_back =  ActiveRecord::Base.connection.execute("SELECT * FROM demands WHERE validated IS TRUE AND taken IS NOT TRUE AND user_id = #{current_user.id}")
    @demands = @documents_to_get_back.map { |d| d["id"].to_i }
    @demands = @demands.to_s.sub("[", "(").sub("]", ")")
    @demands.eql?("()") ? @demands_sql = "" : @demands_sql = "AND demand_id IN #{@demands}"
    @documents_to_get_back_users = ActiveRecord::Base.connection.execute("SELECT DISTINCT user_id FROM demands WHERE validated IS TRUE AND taken IS NOT TRUE AND user_id = #{current_user.id}")
    @books_to_get_back = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE validated IS TRUE AND taken IS NOT TRUE #{@demands_sql}")
  
    @document_to_bring_back = ActiveRecord::Base.connection.execute("SELECT * FROM demands WHERE taken IS TRUE AND returned IS NULL AND book_damaged IS NULL AND user_id = #{current_user.id}")
    @demands = @document_to_bring_back.map { |d| d["id"].to_i }
    @demands = @demands.to_s.sub("[", "(").sub("]", ")")
    @demands.eql?("()") ? @demands_sql = "" : @demands_sql = "AND demand_id IN #{@demands}"
    @document_to_bring_back_users = ActiveRecord::Base.connection.execute("SELECT DISTINCT user_id FROM demands WHERE taken IS TRUE AND returned IS NULL AND book_damaged IS NULL AND user_id = #{current_user.id}")
    @books_to_bring_back = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE taken IS TRUE AND returned IS NULL AND book_damaged IS NULL #{@demands_sql}")
  
    @document_brought_back = ActiveRecord::Base.connection.execute("SELECT * FROM demands WHERE returned = TRUE AND user_id = #{current_user.id}")
    @demands = @document_brought_back.map { |d| d["id"].to_i }
    @demands = @demands.to_s.sub("[", "(").sub("]", ")")
    @demands.eql?("()") ? @demands_sql = "" : @demands_sql = "AND demand_id IN #{@demands}"
    @document_brought_back_users = ActiveRecord::Base.connection.execute("SELECT DISTINCT user_id FROM demands WHERE returned = TRUE AND user_id = #{current_user.id}")
    @books_brought_back = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE returned = TRUE #{@demands_sql}")
  end
  
  def personnal_demands
    @demands = Demand.where("returned IS TRUE AND user_id = #{current_user.id}").order("created_at DESC").page(params[:page]).per(8)
  end
  
  def list_documents_in_demand
    @demand = Demand.find_by_id(params[:id])
    if @demand.blank?
      redirect_to personnal_demands_list_path   
    else
      @books = @demand.books.page(params[:page]).per(8)
    end
  end
  
  def departments_on_hold
    @departments = Department.order("name ASC")
  end
  
  def departments_validated
    @departments = Department.order("name ASC")
  end
  
  def departments_to_get_back
    @departments = Department.order("name ASC")
  end
  
  def departments_to_bring_back
    @departments = Department.order("name ASC")
  end
  
  def departments_returned
    @departments = Department.order("name ASC")
  end
  
  def list_users_on_hold
    @qualification = Qualification.find_by_id(params[:qualification_id])
    @department = @qualification.department
    @users = @qualification.users.where("profile_id != #{Profile.find_by_shortcut("ADMIN").id} AND profile_id != #{Profile.find_by_shortcut("CD-BD").id} AND profile_id != #{Profile.find_by_shortcut("CSADP-BD").id} AND profile_id != #{Profile.find_by_shortcut("AGC").id}")  
  end
  
  def list_users_validated
    @qualification = Qualification.find_by_id(params[:qualification_id])
    @department = @qualification.department
    @users = @qualification.users.where("profile_id != #{Profile.find_by_shortcut("ADMIN").id} AND profile_id != #{Profile.find_by_shortcut("CD-BD").id} AND profile_id != #{Profile.find_by_shortcut("CSADP-BD").id} AND profile_id != #{Profile.find_by_shortcut("AGC").id}")  
  end
  
  def list_users_to_get_back
    @qualification = Qualification.find_by_id(params[:qualification_id])
    @department = @qualification.department
    @users = @qualification.users.where("profile_id != #{Profile.find_by_shortcut("ADMIN").id} AND profile_id != #{Profile.find_by_shortcut("CD-BD").id} AND profile_id != #{Profile.find_by_shortcut("CSADP-BD").id} AND profile_id != #{Profile.find_by_shortcut("AGC").id}")  
  end
  
  def list_users_to_bring_back
    @qualification = Qualification.find_by_id(params[:qualification_id])
    @department = @qualification.department
    @users = @qualification.users.where("profile_id != #{Profile.find_by_shortcut("ADMIN").id} AND profile_id != #{Profile.find_by_shortcut("CD-BD").id} AND profile_id != #{Profile.find_by_shortcut("CSADP-BD").id} AND profile_id != #{Profile.find_by_shortcut("AGC").id}")  
  end
  
  def list_users_returned
    @qualification = Qualification.find_by_id(params[:qualification_id])
    @department = @qualification.department
    @users = @qualification.users.where("profile_id != #{Profile.find_by_shortcut("ADMIN").id} AND profile_id != #{Profile.find_by_shortcut("CD-BD").id} AND profile_id != #{Profile.find_by_shortcut("CSADP-BD").id} AND profile_id != #{Profile.find_by_shortcut("AGC").id}")  
  end
  
  def demands_on_hold
    @user = User.find_by_id(params[:user_id])
    @demands = @user.demands.where("on_hold IS TRUE").order("created_at DESC")
  end
  
  def demands_validated
    @user = User.find_by_id(params[:user_id])
    @demands = @user.demands.where("validated IS FALSE AND book_left IS NOT TRUE AND unavailable IS NOT TRUE").order("created_at DESC")
  end
  
  def demands_to_get_back
    @user = User.find_by_id(params[:user_id])
    @demands = @user.demands.where("validated IS TRUE AND taken IS NOT TRUE").order("created_at DESC")
  end
  
  def demands_to_bring_back
    @user = User.find_by_id(params[:user_id])
    @demands = @user.demands.where("taken IS TRUE AND returned IS NULL AND book_damaged IS NULL").order("created_at DESC")
  end
  
  def demands_returned
    @user = User.find_by_id(params[:user_id])
    @demands = @user.demands.where("returned = TRUE").order("created_at DESC")
  end
  
end
