class DemandsController < ApplicationController

  before_filter :sign_out_disabled_users
  prepend_before_filter :authenticate_user!
  
  layout :layout_used

  def history
    @demands = current_user.demands.order("created_at DESC")
  end
  
  def csadp_bd_on_hold
    @demands = Demand.where("validated IS NULL AND unavailable IS NULL").order("created_at DESC").page(params[:page]).per(8)
  end
  
  def statistics
  
  end 
  
  def csadp_request_validation(demand)
    # Envoi d'email de notification
    Thread.new do
      @user = [] << User.find_by_id(demand.user_id).email
      @demand_date = "#{demand.created_at.strftime('%d-%m-%y')} à #{demand.created_at.strftime('%Hh %Mmn')}"
      Notifier.csadp_request_validation(current_user.full_name, current_user.show_qualification, @user, @demand_date).deliver
      if (ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?)
        ActiveRecord::Base.connection.close
      end
    end  
  end
   
  
  def global_validation
    @demand_status = ""
    @current_time = DateTime.now
    @demand = Demand.find_by_id(params[:demand_id])
    
    ActiveRecord::Base.connection.execute("UPDATE demands SET validated = FALSE, validated_by = #{current_user.id}, validated_by_at = '#{@current_time}', on_hold = NULL WHERE on_hold IS NOT NULL AND id = #{@demand.id}")
    ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{@demand.id}").each do |book_demand|
      ActiveRecord::Base.connection.execute("UPDATE books_demands SET validated = FALSE, validated_by = #{current_user.id}, validated_by_at = '#{@current_time}', on_hold = NULL WHERE demand_id = #{@demand.id} AND book_id = #{book_demand["book_id"]} AND on_hold IS NOT NULL AND validated IS NULL")
    end
    
    # Envoi d'email de notification
    csadp_request_validation(@demand) 
    
    if all_books_in_demand_validated?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET on_hold = NULL WHERE id = #{@demand.id}")      
    end
    if demand_partially_validated?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET unavailable = TRUE, on_hold = NULL WHERE id = #{@demand.id}")   
    end
    @demand_status = old_sql_display_demand_status(@demand.id)
    
    render :text => @demand_status
  end
  
  def global_rejection
    @demand_status = ""
    @current_time = DateTime.now
    @demand = Demand.find_by_id(params[:demand_id])
    
    ActiveRecord::Base.connection.execute("UPDATE demands SET unavailable = TRUE, unavailable_by = #{current_user.id}, unavailable_by_at = '#{@current_time}', on_hold = NULL WHERE on_hold IS NOT NULL AND id = #{params[:demand_id]}")
    #@demand.update_attributes(unavailable: true, on_hold: nil)
    ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{params[:demand_id]}").each do |book_demand|
      @book = Book.find_by_id(book_demand["book_id"])
      @book.update_attributes(total_quantity: @book.total_quantity - 1)
      ActiveRecord::Base.connection.execute("UPDATE books_demands SET unavailable = TRUE, unavailable_by = #{current_user.id}, unavailable_by_at = '#{@current_time}', on_hold = NULL, comments = '#{params[:comments]}' WHERE demand_id = #{params[:demand_id]} AND book_id = #{book_demand["book_id"]} AND on_hold IS NOT NULL AND validated IS NULL")
    end
    
    # Envoi d'email de notification
    csadp_request_validation(@demand) 
    
    if all_books_in_demand_rejected?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET unavailable = TRUE, on_hold = NULL WHERE id = #{params[:demand_id]}")
    end
    if demand_partially_validated?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET validated = FALSE, unavailable = TRUE, on_hold = NULL WHERE id = #{params[:demand_id]}")
    end
    @demand_status = old_sql_display_demand_status(@demand.id)
    
    render :text => @demand_status
  end
  
  def global_demand_status
    render :text => display_demand_book_status(params[:demand_id], params[:book_id])
  end
  
  def partial_validation
    @demand_status = ""
    @current_time = DateTime.now
    
    ActiveRecord::Base.connection.execute("UPDATE books_demands SET validated = FALSE, validated_by = #{current_user.id}, validated_by_at = '#{@current_time}', on_hold = NULL WHERE demand_id = #{params[:demand_id]} AND book_id = #{params[:book_id]}")
    
    if all_books_in_demand_validated?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET validated = FALSE, validated_by = #{current_user.id}, validated_by_at = '#{@current_time}', on_hold = NULL WHERE id = #{params[:demand_id]}")
      @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe
      # Envoi d'email de notification
      csadp_request_validation(Demand.find_by_id(params[:demand_id]))
    end
    if demand_partially_validated?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET validated = FALSE, unavailable = TRUE, on_hold = NULL WHERE id = #{params[:demand_id]}") 
      @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe     
      # Envoi d'email de notification
      csadp_request_validation(Demand.find_by_id(params[:demand_id]))
    end    
       
    render :text => display_demand_book_status(params[:demand_id], params[:book_id]) << "*" << @demand_status
  end
  
  def partial_rejection
    @demand_status = ""
    @current_time = DateTime.now
    
    ActiveRecord::Base.connection.execute("UPDATE books_demands SET validated = FALSE, unavailable_by = #{current_user.id}, unavailable_by_at = '#{@current_time}', unavailable = TRUE, on_hold = NULL, comments = '#{params[:comments]}' WHERE demand_id = #{params[:demand_id]} AND book_id = #{params[:book_id]}")
    @book = Book.find_by_id(params[:book_id])
    @book.update_attributes(total_quantity: @book.total_quantity - 1)
       
    if all_books_in_demand_rejected?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET unavailable = TRUE, unavailable_by = #{current_user.id}, unavailable_by_at = '#{@current_time}', on_hold = NULL WHERE id = #{params[:demand_id]}")
      @demand_status = "#{display_demand_status(Demand.find_by_id(params[:demand_id]))}".html_safe
      # Envoi d'email de notification
      csadp_request_validation(Demand.find_by_id(params[:demand_id]))
    end
    if demand_partially_validated?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET validated = FALSE, unavailable = TRUE, on_hold = NULL WHERE id = #{params[:demand_id]}")   
      @demand_status = "#{display_demand_status(Demand.find_by_id(params[:demand_id]))}".html_safe 
      # Envoi d'email de notification
      csadp_request_validation(Demand.find_by_id(params[:demand_id]))
    end    
        
    render :text => display_demand_book_status(params[:demand_id], params[:book_id]) << "*" << @demand_status
  end
  
  def lv_on_hold
    @demands = current_user.demands.where("on_hold IS TRUE").order("created_at DESC").page(params[:page]).per(8)
  end
  
  def lv_validated
    @demands = current_user.demands.where("((validated IS FALSE  AND unavailable IS TRUE) OR validated IS FALSE) AND book_left IS NOT TRUE").order("created_at DESC").page(params[:page]).per(8)
  end
  
  def employee_request_validation(demand)
    # Envoi d'email de notification
    Thread.new do      
      @agc = User.where("profile_id = #{Profile.find_by_shortcut('AGC').id} AND published IS NOT FALSE")
      if !@agc.blank?
        @user = [] << User.find_by_id(demand.user_id).email
        @demand_date = "#{demand.created_at.strftime('%d-%m-%y')} à #{demand.created_at.strftime('%Hh %Mmn')}"
        @agc = @agc.map { |user| user.email }
        Notifier.employee_request_validation(current_user.full_name, current_user.show_qualification, @agc, @demand_date).deliver
        if (ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?)
          ActiveRecord::Base.connection.close
        end
      end
    end  
  end
  
  def lv_global_validation
    @demand_status = ""
    @current_time = DateTime.now
    @demand = Demand.find_by_id(params[:demand_id])
    
    ActiveRecord::Base.connection.execute("UPDATE demands SET validated = TRUE, validated_at = '#{@current_time}' WHERE id = #{@demand.id}")
    ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{@demand.id}").each do |book_demand|
      ActiveRecord::Base.connection.execute("UPDATE books_demands SET validated = TRUE, validated_at = '#{@current_time}' WHERE demand_id = #{@demand.id} AND book_id = #{book_demand["book_id"]} AND (book_left IS NOT TRUE AND validated IS NOT TRUE AND unavailable IS NOT TRUE)")
    end
    
    # Envoi d'email de notification
    employee_request_validation(@demand)
    
    #if all_books_in_demand_validated?(params[:demand_id])
      #ActiveRecord::Base.connection.execute("UPDATE demands SET on_hold = NULL WHERE id = #{@demand.id}")      
    #end
    #if demand_partially_validated?(params[:demand_id])
      #ActiveRecord::Base.connection.execute("UPDATE demands SET unavailable = TRUE, on_hold = NULL WHERE id = #{@demand.id}")   
    #end
    @demand_status = old_sql_display_demand_status(@demand.id)
    
    render :text => @demand_status
  end
  
  def lv_global_rejection
    @demand_status = ""
    @current_time = DateTime.now
    @demand = Demand.find_by_id(params[:demand_id])
    
    ActiveRecord::Base.connection.execute("UPDATE demands SET book_left = TRUE, book_left_at = '#{@current_time}' WHERE id = #{@demand.id}")
    ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{@demand.id}").each do |book_demand|
      @book = Book.find_by_id(book_demand["book_id"])
      @book.update_attributes(quantity_in_stock: @book.quantity_in_stock + 1)
      ActiveRecord::Base.connection.execute("UPDATE books_demands SET book_left = TRUE, book_left_at = '#{@current_time}' WHERE demand_id = #{@demand.id} AND book_id = #{book_demand["book_id"]} AND (book_left IS NOT TRUE AND validated IS NOT TRUE AND unavailable IS NOT TRUE)")
    end
    
    if lv_any_books_in_demand_validated?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET validated = TRUE WHERE id = #{params[:demand_id]}")
      # Envoi d'email de notification
      employee_request_validation(@demand)
    end
        
    #if demand_partially_validated?(params[:demand_id])
      #ActiveRecord::Base.connection.execute("UPDATE demands SET unavailable = TRUE, on_hold = NULL WHERE id = #{@demand.id}")   
    #end
    @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe
    
    render :text => @demand_status
  end
  
  def lv_partial_validation
    @demand_status = ""
    @current_time = DateTime.now
    ActiveRecord::Base.connection.execute("UPDATE books_demands SET validated = TRUE, validated_at = '#{@current_time}' WHERE demand_id = #{params[:demand_id]} AND book_id = #{params[:book_id]}")
    
    if lv_any_books_in_demand_validated?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET validated = TRUE, validated_at = '#{@current_time}' WHERE id = #{params[:demand_id]}")
      @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe
      # Envoi d'email de notification
      employee_request_validation(Demand.find_by_id(params[:demand_id]))
    end
    #if demand_partially_validated?(params[:demand_id])
      #ActiveRecord::Base.connection.execute("UPDATE demands SET validated = TRUE WHERE id = #{params[:demand_id]}") 
      #@demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe     
    #end    
       
    render :text => display_demand_book_status(params[:demand_id], params[:book_id]) << "*" << @demand_status
  end
  
  def lv_partial_rejection
    @demand_status = ""
    @current_time = DateTime.now
    ActiveRecord::Base.connection.execute("UPDATE books_demands SET book_left = TRUE, book_left_at = '#{@current_time}' WHERE demand_id = #{params[:demand_id]} AND book_id = #{params[:book_id]}")
    @book = Book.find_by_id(params[:book_id])
    @book.update_attributes(quantity_in_stock: @book.quantity_in_stock + 1)
    
    if lv_any_books_in_demand_validated?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET validated = TRUE, validated_at = '#{@current_time}' WHERE id = #{params[:demand_id]}")
      @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe
      # Envoi d'email de notification
      employee_request_validation(Demand.find_by_id(params[:demand_id]))
    end
    if lv_all_books_in_demand_rejected?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET book_left = TRUE, book_left_at = '#{@current_time}' WHERE id = #{params[:demand_id]}") 
      @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe   
    end    
       
    render :text => display_demand_book_status(params[:demand_id], params[:book_id]) << "*" << @demand_status
  end
  
  def to_get_back
    @demands = current_user.demands.where("validated IS TRUE AND taken IS NOT TRUE").order("created_at DESC").page(params[:page]).per(8)
  end
  
  def csadp_bd_to_get_back
    @demands = Demand.where("validated IS TRUE AND taken IS NOT TRUE").order("created_at DESC")
  end
  
  def agc_validated 
    @demands = Demand.where("validated IS TRUE AND taken IS NOT TRUE").order("created_at DESC").page(params[:page]).per(8)
  end
  
  # Envoi d'email de notification
  def agc_request_validation(demand)
    # Envoi d'email de notification
    Thread.new do
      @user = [] << User.find_by_id(demand.user_id).email
      @demand_date = "#{demand.created_at.strftime('%d-%m-%y')} à #{demand.created_at.strftime('%Hh %Mmn')}"
      Notifier.agc_request_validation(current_user.full_name, current_user.show_qualification, @user, @demand_date).deliver
      if (ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?)
        ActiveRecord::Base.connection.close
      end
    end  
  end
  
  def agc_global_validation
    @demand_status = ""
    @current_time = DateTime.now
    @demand = Demand.find_by_id(params[:demand_id])
    
    ActiveRecord::Base.connection.execute("UPDATE demands SET taken = TRUE, taken_by = #{current_user.id}, taken_by_at = '#{@current_time}' WHERE id = #{@demand.id}")
    ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{@demand.id}").each do |book_demand|
      ActiveRecord::Base.connection.execute("UPDATE books_demands SET taken = TRUE, taken_by = #{current_user.id}, taken_by_at = '#{@current_time}' WHERE demand_id = #{@demand.id} AND book_id = #{book_demand["book_id"]} AND (VALIDATED IS TRUE AND taken IS NOT TRUE AND book_left IS NOT TRUE)")
    end
    
    # Envoi d'email de notification
    agc_request_validation(@demand)
    
    #if all_books_in_demand_validated?(params[:demand_id])
      #ActiveRecord::Base.connection.execute("UPDATE demands SET on_hold = NULL WHERE id = #{@demand.id}")      
    #end
    #if demand_partially_validated?(params[:demand_id])
      #ActiveRecord::Base.connection.execute("UPDATE demands SET unavailable = TRUE, on_hold = NULL WHERE id = #{@demand.id}")   
    #end
    @demand_status = old_sql_display_demand_status(@demand.id)
    
    render :text => @demand_status
  end
  
  def agc_partial_validation
    @demand_status = ""
    @current_time = DateTime.now
    ActiveRecord::Base.connection.execute("UPDATE books_demands SET taken = TRUE, taken_by = #{current_user.id}, taken_by_at = '#{@current_time}' WHERE demand_id = #{params[:demand_id]} AND book_id = #{params[:book_id]}")
    
    if agc_any_books_in_demand_taken?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET taken = TRUE, taken_by = #{current_user.id}, taken_by_at = '#{@current_time}' WHERE id = #{params[:demand_id]}")
      @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe
      # Envoi d'email de notification
      agc_request_validation(Demand.find_by_id(params[:demand_id]))
    end
    #if demand_partially_validated?(params[:demand_id])
      #ActiveRecord::Base.connection.execute("UPDATE demands SET validated = TRUE WHERE id = #{params[:demand_id]}") 
      #@demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe     
    #end    
       
    render :text => display_demand_book_status(params[:demand_id], params[:book_id]) << "*" << @demand_status
  end
  
  def agc_to_return
    @demands = Demand.where("returned IS FALSE").order("created_at DESC").page(params[:page]).per(8)
  end
  
  def agc_brought_back
    @demand_status = ""
    @current_time = DateTime.now
    ActiveRecord::Base.connection.execute("UPDATE demands SET returned = TRUE, returned_by = #{current_user.id}, returned_by_at = '#{@current_time}' WHERE id = #{params[:demand_id]}")
    ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{params[:demand_id]}").each do |book_demand|
      if book_demand["validated"] == "t" and book_demand["book_damaged"] == nil and book_demand["taken"] == "t" and book_demand["returned"] == "f" and book_demand["unavailable"] == nil and book_demand["book_left"] == nil
        ActiveRecord::Base.connection.execute("UPDATE books_demands SET returned = TRUE, returned_by = #{current_user.id}, returned_by_at = '#{@current_time}' WHERE demand_id = #{book_demand["demand_id"]} AND book_id = #{book_demand["book_id"]}")
        @book = Book.find_by_id(book_demand["book_id"])
        @book.update_attributes(quantity_in_stock: @book.quantity_in_stock + 1)  
        
        # si le livre a été réservé, on crée une demande
        reserve_book(@book)
      end
    end
       
    if some_books_damaged?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET returned = TRUE, returned_by = #{current_user.id}, returned_by_at = '#{@current_time}', book_damaged = TRUE, damaged_by = #{current_user.id}, book_damaged_by_at = '#{@current_time}' WHERE id = #{params[:demand_id]}")        
      @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe
    end
    if no_book_damaged?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET returned = TRUE, returned_by = #{current_user.id}, returned_by_at = '#{@current_time}' WHERE id = #{params[:demand_id]}")        
      @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe
    end
    #@demand_status = old_sql_display_demand_status(params[:demand_id])
    
    render :text => @demand_status
  end
  
  def reserve_book(book)
    @reservation = Reservation.where("book_id = #{book.id} AND status IS NOT TRUE").order("created_at ASC") 
    if !@reservation.blank?
      @reservation = @reservation.first
      @demand = Demand.create(user_id: @reservation.user_id, on_hold: true)
      book.update_attributes(quantity_in_stock: book.quantity_in_stock - 1)
      @demand.books << book
      ActiveRecord::Base.connection.execute("UPDATE books_demands SET on_hold = TRUE WHERE demand_id = #{@demand.id} AND book_id = #{book.id}")
      @reservation.update_attributes(status: true, reserved_at: DateTime.now)
    end
  end
  
  def agc_damaged
    @demand_status = ""
    @current_time = DateTime.now
    ActiveRecord::Base.connection.execute("UPDATE demands SET returned = NULL, book_damaged = TRUE, damaged_by = #{current_user.id}, book_damaged_by_at = '#{@current_time}' WHERE id = #{params[:demand_id]}")
    ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{params[:demand_id]}").each do |book_demand|
      ActiveRecord::Base.connection.execute("UPDATE books_demands SET returned = NULL, book_damaged = TRUE, damaged_by = #{current_user.id}, book_damaged_by_at = '#{@current_time}' WHERE demand_id = #{params[:demand_id]} AND book_id = #{book_demand["book_id"]} AND (validated IS TRUE AND book_damaged IS NULL AND taken IS TRUE AND returned IS FALSE AND unavailable IS NULL AND book_left IS NULL)")
      @book = Book.find_by_id(book_demand["book_id"])
      @book.update_attributes(quantity_in_stock: @book.total_quantity - 1)
    end
    
    if agc_some_books_returned?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET returned = TRUE, returned_by = #{current_user.id}, returned_by_at = '#{@current_time}', book_damaged = TRUE, damaged_by = #{current_user.id}, book_damaged_by_at = '#{@current_time}' WHERE id = #{params[:demand_id]}")
      @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe
    end 
    if agc_all_books_damaged?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET book_damaged = TRUE, damaged_by = #{current_user.id}, book_damaged_by_at = '#{@current_time}' WHERE id = #{params[:demand_id]}")
      @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe
    end
    
    #@demand_status = old_sql_display_demand_status(params[:demand_id])
    
    render :text => @demand_status
  end
  
  def agc_partial_return
    @demand_status = ""
    @current_time = DateTime.now
    ActiveRecord::Base.connection.execute("UPDATE books_demands SET returned = TRUE, returned_by = #{current_user.id}, returned_by_at = '#{@current_time}' WHERE demand_id = #{params[:demand_id]} AND book_id = #{params[:book_id]}")
    @book = Book.find_by_id(params[:book_id])
    @book.update_attributes(quantity_in_stock: @book.quantity_in_stock + 1)
    
    # si le livre a été réservé, on crée une demande
    reserve_book(@book)
    
    if some_books_damaged?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET returned = TRUE, returned_by = #{current_user.id}, returned_by_at = '#{@current_time}', book_damaged = TRUE, damaged_by = #{current_user.id}, book_damaged_by_at = '#{@current_time}' WHERE id = #{params[:demand_id]}")        
      @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe
    end
    if no_book_damaged?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET returned = TRUE, returned_by = #{current_user.id}, returned_by_at = '#{@current_time}' WHERE id = #{params[:demand_id]}")        
      @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe
    end
       
    render :text => display_demand_book_status(params[:demand_id], params[:book_id]) << "*" << @demand_status
  end
  
  def agc_partial_damage
    @demand_status = ""
    @current_time = DateTime.now
    ActiveRecord::Base.connection.execute("UPDATE books_demands SET returned = NULL, book_damaged = TRUE, damaged_by = #{current_user.id}, book_damaged_by_at = '#{@current_time}' WHERE demand_id = #{params[:demand_id]} AND book_id = #{params[:book_id]}")
    @book = Book.find_by_id(params[:book_id])
    @book.update_attributes(total_quantity: @book.total_quantity - 1)
    
    if agc_some_books_returned?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET returned = TRUE, returned_by = #{current_user.id}, returned_by_at = '#{@current_time}', book_damaged = TRUE, damaged_by = #{current_user.id}, book_damaged_by_at = '#{@current_time}' WHERE id = #{params[:demand_id]}")
      @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe
    end   
    if agc_all_books_damaged?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET book_damaged = TRUE, damaged_by = #{current_user.id}, book_damaged_by_at = '#{@current_time}' WHERE id = #{params[:demand_id]}")
      @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe
    end  
    
    render :text => display_demand_book_status(params[:demand_id], params[:book_id]) << "*" << @demand_status
  end
    
  def agc_history
    @demands = Demand.where("taken IS TRUE").order("created_at DESC")
  end
  
  def lv_to_bring_back
    @demands = Demand.where("taken IS TRUE AND returned IS NULL AND book_damaged IS NULL").order("created_at DESC").page(params[:page]).per(8)
  end
  
  def employee_request_return_or_damage(demand)
    # Envoi d'email de notification
    Thread.new do      
      @agc = User.where("profile_id = #{Profile.find_by_shortcut('AGC').id} AND published IS NOT FALSE")
      if !@agc.blank?
        @user = [] << User.find_by_id(demand.user_id).email
        @demand_date = "#{demand.created_at.strftime('%d-%m-%y')} à #{demand.created_at.strftime('%Hh %Mmn')}"
        @agc = @agc.map { |user| user.email }
        Notifier.employee_request_return_or_damage(current_user.full_name, current_user.show_qualification, @agc, @demand_date).deliver
        if (ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?)
          ActiveRecord::Base.connection.close
        end
      end
    end 
  end
  
  def lv_bring_back
    @demand_status = ""
    @current_time = DateTime.now
    @demand = Demand.find_by_id(params[:demand_id])
    
    ActiveRecord::Base.connection.execute("UPDATE demands SET returned = FALSE, returned_at = '#{@current_time}' WHERE id = #{@demand.id}")
    ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{@demand.id}").each do |book_demand|
      ActiveRecord::Base.connection.execute("UPDATE books_demands SET returned = FALSE, returned_at = '#{@current_time}' WHERE demand_id = #{@demand.id} AND book_id = #{book_demand["book_id"]} AND (validated IS TRUE AND book_damaged IS NULL AND taken IS TRUE AND returned IS NULL AND unavailable IS NOT TRUE AND book_left IS NOT TRUE)")
      #AND (taken IS TRUE AND returned IS NOT TRUE AND unavailable IS NOT TRUE AND book_left IS NOT TRUE)
    end
    
    # Envoi d'email de notification
    employee_request_return_or_damage(@demand)
    
    if some_books_damaged?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET returned = FALSE, book_damaged = TRUE WHERE id = #{params[:demand_id]}")        
    end
    @demand_status = old_sql_display_demand_status(@demand.id)
    
    render :text => @demand_status
  end
  
  def lv_damaged
    @demand_status = ""
    @current_time = DateTime.now
    @demand = Demand.find_by_id(params[:demand_id])
    ActiveRecord::Base.connection.execute("UPDATE demands SET book_damaged = TRUE, book_damaged_at = '#{@current_time}' WHERE id = #{@demand.id}")
    ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{@demand.id}").each do |book_demand|
      ActiveRecord::Base.connection.execute("UPDATE books_demands SET book_damaged = TRUE, book_damaged_at = '#{@current_time}' WHERE demand_id = #{@demand.id} AND book_id = #{book_demand["book_id"]} AND (validated IS TRUE AND book_damaged IS NULL AND taken IS TRUE AND returned IS NULL AND unavailable IS NOT TRUE AND book_left IS NOT TRUE)")
      @book = Book.find_by_id(book_demand["book_id"])
      @book.update_attributes(total_quantity: @book.total_quantity - 1)
    end
    
    if some_books_returned?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET returned = FALSE, returned_at = '#{@current_time}', book_damaged = TRUE, book_damaged_at = '#{@current_time}' WHERE id = #{params[:demand_id]}")
    end 
    
    # Envoi d'email de notification
    employee_request_return_or_damage(@demand) 
    
    @demand_status = old_sql_display_demand_status(@demand.id)
    
    render :text => @demand_status
  end
  
  def lv_partial_return
    @demand_status = ""
    @current_time = DateTime.now
    ActiveRecord::Base.connection.execute("UPDATE books_demands SET returned = FALSE, returned_at = '#{@current_time}' WHERE demand_id = #{params[:demand_id]} AND book_id = #{params[:book_id]}")
    
    if some_books_damaged?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET returned = FALSE, returned_at = '#{@current_time}', book_damaged = TRUE, book_damaged_at = '#{@current_time}' WHERE id = #{params[:demand_id]}")        
      @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe
      # Envoi d'email de notification
      employee_request_return_or_damage(@Demand.find_by_id(params[:demand_id]))
    end
    if all_books_returned?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET returned = FALSE, returned_at = '#{@current_time}' WHERE id = #{params[:demand_id]}")
      @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe
      # Envoi d'email de notification
      employee_request_return_or_damage(@Demand.find_by_id(params[:demand_id]))
    end   
       
    render :text => display_demand_book_status(params[:demand_id], params[:book_id]) << "*" << @demand_status
  end
  
  def lv_partial_damage
    @demand_status = ""
    @current_time = DateTime.now
    ActiveRecord::Base.connection.execute("UPDATE books_demands SET book_damaged = TRUE, book_damaged_at = '#{@current_time}' WHERE demand_id = #{params[:demand_id]} AND book_id = #{params[:book_id]}")
    @book = Book.find_by_id(params[:book_id])
    @book.update_attributes(total_quantity: @book.total_quantity - 1)
    
    if all_books_damaged?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET book_damaged = TRUE, book_damaged_at = '#{@current_time}' WHERE id = #{params[:demand_id]}")
      @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe
      # Envoi d'email de notification
      employee_request_return_or_damage(@Demand.find_by_id(params[:demand_id]))
    end    
    if some_books_returned?(params[:demand_id])
      ActiveRecord::Base.connection.execute("UPDATE demands SET returned = FALSE, returned_at = '#{@current_time}', book_damaged = TRUE, book_damaged_at = '#{@current_time}' WHERE id = #{params[:demand_id]}")
      @demand_status = "#{old_sql_display_demand_status(params[:demand_id])}".html_safe
      # Envoi d'email de notification
      employee_request_return_or_damage(@Demand.find_by_id(params[:demand_id]))
    end   
    
    render :text => display_demand_book_status(params[:demand_id], params[:book_id]) << "*" << @demand_status
  end
  
end
