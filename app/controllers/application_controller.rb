class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  helper_method :department_status, :display_demand_status, :demand_on_hold, :book_returned_to_library_or_damaged?, :book_demand_to_bring_back?, :book_demand_taken?, :book_demand_unavailable?, :agc_book_demand_left_or_unavailable?, :display_demand_book_status, :book_demand_on_hold, :book_demand_validated_or_left?
  #prepend_before_filter :authenticate_user!, :cache_buster
  
  private
  
    def department_status(department)
      @status_style = ""
      if department.published == false        
        @status_style = "<span class = 'label label-important'>Désactivé</span>".html_safe
      else
        @status_style = "<span class = 'label label-success'>Activé</span>".html_safe
      end
    end
  
    def display_demand_status(demand)
      @status = ""
      if demand.on_hold.eql?(true)
        @status = "<span class = 'label label-info'>En attente</span>"
      end
      if demand.validated.eql?(false)
        @status = "<span class = 'label label-warning'>Validée</span>"
      end     
      if demand.validated.eql?(true)
        @status = "<span class = 'label label-success'>Validée</span>"
      end
      if demand.troubles_in.eql?(true)
        @status = "<span class = 'label label-important'>Rendus</span>"
      end
      if demand.unavailable.eql?(true)
        @status = "<span class = 'label label-important'>Non disponible</span>"
      end
      if demand.validated.eql?(true) and demand.unavailable.eql?(true)
        @status = "<span class = 'label label-success'>Validée</span>"
      end
      if demand.validated.eql?(false) and demand.unavailable.eql?(true)
        @status = "<span class = 'label label-important'>Validée</span>"
      end
      if demand.book_left.eql?(true)
        @status = "<span class = 'label label-important'>Annulée</span>"
      end
      if demand.validated.eql?(true) and demand.book_left.eql?(true)
        @status = "<span class = 'label label-success'>Validée</span>"
      end
      if demand.validated.eql?(true) and demand.book_left.eql?(true) and demand.unavailable.eql?(true)
        @status = "<span class = 'label label-success'>Validée</span>"
      end
      if demand.taken.eql?(true)
        @status = "<span class = 'label label-success'>Retirés</span>"
      end
      if demand.returned.eql?(false)
        @status = "<span class = 'label label-warning'>Rendus</span>"
      end
      if demand.returned.eql?(true)
        @status = "<span class = 'label label-success'>Rendus</span>"
      end
      
      if demand.returned.eql?(true) and demand.book_damaged.eql?(true)
        @status = "<span class = 'label label-important'>Rendus</span>"
      end

      @status.html_safe
    end
    
    def old_sql_display_demand_status(demand_id)
      @my_demand = ActiveRecord::Base.connection.execute("SELECT * FROM demands WHERE id = #{demand_id}").first
      @status = ""
      if @my_demand["on_hold"] == "t"
        @status = "<span class = 'label label-info'>En attente</span>"
      end
      if @my_demand["validated"] == "f"
        @status = "<span class = 'label label-warning'>Validée</span>"
      end     
      if @my_demand["validated"] == "t"
        @status = "<span class = 'label label-success'>Validée</span>"
      end
      if @my_demand["troubles_in"] == "t"
        @status = "<span class = 'label label-important'>Rendus</span>"
      end
      if @my_demand["unavailable"] == "t"
        @status = "<span class = 'label label-important'>Non disponible</span>"
      end
      if @my_demand["validated"] == "t" and @my_demand["unavailable"] == "t"
        @status = "<span class = 'label label-success'>Validée</span>"
      end
      if @my_demand["validated"] == "f" and @my_demand["unavailable"] == "t"
        @status = "<span class = 'label label-important'>Validée</span>"
      end
      if @my_demand["book_left"] == "t"
        @status = "<span class = 'label label-important'>Annulée</span>"
      end
      if @my_demand["validated"] == "t" and @my_demand["book_left"] == "t"
        @status = "<span class = 'label label-success'>Validée</span>"
      end
      if @my_demand["taken"] == "t"
        @status = "<span class = 'label label-success'>Retirés</span>"
      end
      if @my_demand["returned"] == "f"
        @status = "<span class = 'label label-warning'>Rendus</span>"
      end
      if @my_demand["returned"] == "t"
        @status = "<span class = 'label label-success'>Rendus</span>"
      end
      if @my_demand["book_damaged"] == "t"
        @status = "<span class = 'label label-important'>Endommagés</span>"
      end
      if @my_demand["returned"] == "f" and @my_demand["book_damaged"] == "t"
        @status = "<span class = 'label label-important'>Rendus</span>"
      end
      if @my_demand["returned"] == "t" and @my_demand["book_damaged"] == "t"
        @status = "<span class = 'label label-important'>Rendus</span>"
      end
      #if troubles_in_demand(demand).eql?(true)
        #@status = "<span class = 'label label-important'>Rendus</span>"
      #end
      @status.html_safe
    end
    
    def display_demand_book_status(demand_id, book_id)
      @book_demand = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id} AND book_id = #{book_id}").first
      @book_status = ""
      if @book_demand["on_hold"] == "t"
        @book_status = "<span class = 'label label-info'>En attente</span>"
      end
      if @book_demand["validated"] == "f"
        @book_status = "<span class = 'label label-warning'>Validé</span>"
      end
      if @book_demand["validated"] == "t"
        @book_status = "<span class = 'label label-success'>Validé</span>"
      end     
      if @book_demand["troubles_in"] == "t"
        @book_status = "<span class = 'label label-important'>Rendu</span>"
      end
      if @book_demand["unavailable"] == "t"
        @book_status = "<span class = 'label label-important'>Non disponible</span>"
      end
      if @book_demand["book_left"] == "t"
        @book_status = "<span class = 'label label-important'>Annulé</span>"
      end
      if @book_demand["taken"] == "t"
        @book_status = "<span class = 'label label-success'>Retiré</span>"
      end
      if @book_demand["returned"] == "f"
        @book_status = "<span class = 'label label-warning'>Rendu</span>"
      end
      if @book_demand["returned"] == "t"
        @book_status = "<span class = 'label label-success'>Rendu</span>"
      end
      if @book_demand["book_damaged"] == "t"
        @book_status = "<span class = 'label label-important'>Endommagé</span>"
      end
=begin
      if @book_demand["validated"] == "t" and @book_demand["unavailable"] == "t"
        @book_status = "<span class = 'label label-success'>Validée</span>"
      end
      if @book_demand["validated"] == "f" and @book_demand["unavailable"] == "t"
        @book_status = "<span class = 'label label-important'>Validée</span>"
      end
      
      #if troubles_in_demand(demand).eql?(true)
        #@status = "<span class = 'label label-important'>Rendus</span>"
      #end
=end
      @book_status.html_safe
    end
    
    def demand_on_hold(demand)
      demand.on_hold.eql?(true) ? true : false
    end
    
    def book_demand_on_hold(demand_id, book_id)
      @book_demand = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id} AND book_id = #{book_id}").first
      (@book_demand.blank? or @book_demand["on_hold"] == "t") ? true : false
    end
    
    def book_demand_validated_or_left?(demand_id, book_id)
      @book_demand = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id} AND book_id = #{book_id} AND unavailable IS NOT TRUE").first
      (@book_demand.blank? or @book_demand["validated"] == "t" or @book_demand["book_left"] == "t") ? true : false
    end
    
    def book_demand_taken?(demand_id, book_id)
      @book_demand = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id} AND book_id = #{book_id}").first
      (@book_demand.blank? or @book_demand["taken"] == "t") ? true : false
    end
    
    def book_demand_unavailable?(demand_id, book_id)
      @book_demand = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id} AND book_id = #{book_id}").first
      (@book_demand.blank? or @book_demand["unavailable"] == "t") ? true : false
    end
    
    def book_demand_to_bring_back?(demand_id, book_id)
      @book_demand = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id} AND book_id = #{book_id}").first
      (@book_demand["validated"] == "t" and @book_demand["taken"] == "t" and @book_demand["returned"] != "f" and @book_demand["book_damaged"] != "t") ? true : false
    end
       
    def book_returned_to_library_or_damaged?(demand_id, book_id)
      @book_demand = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id} AND book_id = #{book_id}").first
      (@book_demand["returned"] == "t" or (@book_demand["returned"] == "f" and @book_demand["book_damaged"] == "t") or @book_demand["book_left"] == "t" or @book_demand["book_damaged"] == "t" or @book_demand["unavailable"] == "t") ? true : false
    end
    
    def agc_book_demand_left_or_unavailable?(demand_id, book_id)
      @book_demand = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id} AND book_id = #{book_id} AND unavailable IS NOT TRUE").first
      (@book_demand.blank? or @book_demand["book_left"] == "t" or @book_demand["unavailable"] == "t") ? true : false
    end
    
    def all_books_in_demand_validated?(demand_id)
      @status = false
      @book_demands = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id}")
      @count = 0
      @book_demands.each  do |book_demand|
        if book_demand["validated"] == "f"          
          @count += 1
        end
      end
      if @count.eql?(@book_demands.count)
        @status = true        
      end
      @status
    end
    
    def lv_any_books_in_demand_validated?(demand_id)
      @status = false
      @book_demands = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id}")
      @count = 0
      @counter = 0
      @book_demands.each  do |book_demand|
        if book_demand["validated"] == "t"          
          @count += 1
          @counter += 1
        end
        if book_demand["book_left"] == "t"
          @counter += 1
        end
        if book_demand["unavailable"] == "t"
          @counter += 1
        end
      end
      if @count > 0 and @counter.eql?(@book_demands.count)
        @status = true        
      end
      @status
    end
    
    def some_books_damaged?(demand_id)
      @status = false
      @book_demands = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id}")
      @count = 0
      @counter = 0
      @book_demands.each  do |book_demand|
        if book_demand["returned"] == "t"
          @counter += 1
        end
        if book_demand["book_left"] == "t"
          @counter += 1
        end
        if book_demand["unavailable"] == "t"
          @counter += 1
        end
        if book_demand["book_damaged"] == "t"
          @count += 1
          @counter += 1
        end
      end
      if @counter.eql?(@book_demands.count) and @count > 0
        @status = true        
      end
      @status
    end
    
    def agc_some_books_returned?(demand_id)
      @status = false
      @book_demands = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id}")
      @count = 0
      @counter = 0
      @book_demands.each  do |book_demand|
        if book_demand["returned"] == "t"
          @counter += 1
          @count += 1
        end
        if book_demand["book_left"] == "t"
          @counter += 1
        end
        if book_demand["unavailable"] == "t"
          @counter += 1
        end
        if book_demand["book_damaged"] == "t"          
          @counter += 1
        end
      end
      if @counter.eql?(@book_demands.count) and @count > 0
        @status = true        
      end
      @status
    end
    
    def no_book_damaged?(demand_id)
      @status = false
      @book_demands = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id}")
      @count = 0
      @counter = 0
      @book_demands.each  do |book_demand|
        if book_demand["returned"] == "t"
          @counter += 1
        end
        if book_demand["book_left"] == "t"
          @counter += 1
        end
        if book_demand["unavailable"] == "t"
          @counter += 1
        end
        if book_demand["book_damaged"] == "t"
          @count += 1
          @counter += 1
        end
      end
      if @counter.eql?(@book_demands.count) and @count == 0
        @status = true        
      end
      @status
    end
    
    def agc_all_books_damaged?(demand_id)
      @status = false
      @book_demands = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id}")
      @count = 0
      @counter = 0
      @book_demands.each  do |book_demand|
        if book_demand["returned"] == "t"
          @counter += 1
        end
        if book_demand["book_left"] == "t"
          @counter += 1
        end
        if book_demand["unavailable"] == "t"
          @counter += 1
        end
        if book_demand["book_damaged"] == "t"
          @count += 1
          @counter += 1
        end
      end
      if @count.eql?(@book_demands.count)
        @status = true        
      end
      @status
    end
    
    def some_books_returned?(demand_id)
      @status = false
      @book_demands = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id}")
      @count = 0
      @counter = 0
      @book_demands.each  do |book_demand|
        if book_demand["returned"] == "f"
          @counter += 1
          @count += 1
        end
        if book_demand["book_left"] == "t"
          @counter += 1
        end
        if book_demand["unavailable"] == "t"
          @counter += 1
        end
        if book_demand["book_damaged"] == "t"
          @counter += 1
        end
      end
      if @counter.eql?(@book_demands.count) and @count > 0
        @status = true        
      end
      @status
    end
    
    def all_books_returned?(demand_id)
      @status = false
      @book_demands = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id}")
      @count = 0
      @counter = 0
      @book_demands.each  do |book_demand|
        if book_demand["returned"] == "f"
          @counter += 1
        end
        if book_demand["book_left"] == "t"
          @counter += 1
        end
        if book_demand["unavailable"] == "t"
          @counter += 1
        end
        if book_demand["book_damaged"] == "t"
          @count += 1
          @counter += 1
        end
      end
      if @counter.eql?(@book_demands.count) and @count == 0
        @status = true        
      end
      @status
    end
    
    def all_books_damaged?(demand_id)
      @status = false
      @book_demands = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id}")
      @counter = 0
      @count = 0
      @book_demands.each  do |book_demand|
        if book_demand["book_damaged"] == "t"
          @counter += 1
          @count += 1
        end
        if book_demand["unavailable"] == "t"
          @counter += 1
        end
        if book_demand["book_left"] == "t"
          @counter += 1
        end
      end
      if @counter == @book_demands.count
        @status = true        
      end
      @status
    end
    
    def agc_any_books_in_demand_taken?(demand_id)
      @status = false
      @book_demands = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id}")
      @count = 0
      @counter = 0
      @book_demands.each  do |book_demand|
        if book_demand["taken"] == "t"          
          @count += 1
          @counter += 1
        end
        if book_demand["book_left"] == "t"
          @counter += 1
        end
        if book_demand["unavailable"] == "t"
          @counter += 1
        end
      end
      if @count > 0 and @counter.eql?(@book_demands.count)
        @status = true        
      end
      @status
    end
    
    def all_books_in_demand_rejected?(demand_id)
      @status = false
      @book_demands = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id}")
      @count = 0
      @book_demands.each  do |book_demand|
        if book_demand["unavailable"] == "t"          
          @count += 1
        end
      end
      if @count.eql?(@book_demands.count)
        @status = true       
      end
      @status
    end
    
    def lv_all_books_in_demand_rejected?(demand_id)
      @status = false
      @book_demands = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id}")
      @count = 0
      @book_demands.each  do |book_demand|
        if book_demand["unavailable"] == "t"          
          @count += 1
        end
        if book_demand["book_left"] == "t"          
          @count += 1
        end
      end
      if @count.eql?(@book_demands.count)
        @status = true       
      end
      @status
    end
    
    def demand_partially_validated?(demand_id)
      @status = false
      @book_demands = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id}")
      @count = 0
      @on_hold = 0
      @book_demands.each  do |book_demand|
        book_demand["unavailable"] == "t" ? @count += 1 : false         
        book_demand["on_hold"].blank? ? @on_hold += 1 : false
      end
      if @count > 0 and @count < @book_demands.count and @on_hold == @book_demands.count
        @status = true       
      end
      @status
    end
    
    def lv_demand_partially_validated?(demand_id)
      @status = false
      @book_demands = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand_id}")
      @count = 0
      @on_hold = 0
      @book_demands.each  do |book_demand|
        book_demand["unavailable"] == "t" ? @count += 1 : false         
        book_demand["on_hold"].blank? ? @on_hold += 1 : false
      end
      if @count > 0 and @count < @book_demands.count and @on_hold == @book_demands.count
        @status = true       
      end
      @status
    end
    
    def troubles_in_demand(demand)
      @trouble = false
      ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE demand_id = #{demand.id};").each do |book_demand|
        if book_demand["book_damaged"] == "t"
          @trouble = true
        end
      end
      @trouble
    end
    
    def sign_out_disabled_users
      if current_user.published.eql?(false)
        #redirect_path = after_sign_out_path_for(current_user)
        sign_out(current_user)
        #signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
        #set_flash_message :notice => , :signed_out if signed_out && is_navigational_format?
        flash[:notice] = "Votre compte a été désactivé. Veuillez contacter l'administrateur."
        redirect_to new_user_session_path
        # We actually need to hardcode this as Rails default responder doesn't
        # support returning empty response on GET request
        #respond_to do |format|
        #  format.all { head :no_content }
        #  format.any(*navigational_formats) { redirect_to redirect_path }
        #end
      end
    end
		# Overwriting the sign_out redirect path method
		def after_sign_out_path_for(resource_or_scope)
			new_user_session_path
		end
		
		def after_sign_in_path_for(resource_or_scope)
			#administrator_dashboard_path
			case current_user.short_profile
			  when "ADMIN"
				  administrator_dashboard_path
			  when "LV1"
				  lv_dashboard_path
			  when "LV2"
				  lv_dashboard_path
			  when "CD"
				  cd_dashboard_path
			  when "CD-BD"
				  csadp_bd_demands_on_hold_path
			  when "CSADP-BD"
				  csadp_bd_demands_on_hold_path
				when "AGC"
				  agc_dashboard_path
				when "PE"
				  pe_dashboard_path
			  else
				  new_user_session_path
			  end
		end
		
		def not_a_number?(n)
    	n.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? true : false 
	  end
	  
	  def valid_email?(str)
	    str.to_s.match(/^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i) == nil ? false : true
	  end
	  
	  def capitalization(raw_string)
    	@string_capitalized = ''
    	raw_string.split.each do |name|
    		@string_capitalized << "#{name.capitalize} "
    	end
    	@string_capitalized.strip
    end
    
# Vider le cache des navigateurs	
	  def cache_buster
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end
    
    def layout_used 
    	if current_user.blank?
    	  "sessions"
    	else
			  case current_user.short_profile
		      when "ADMIN"
			      "administrator"
		      when "LV1"
			      "lvs"
		      when "LV2"
			      "lvs"
		      when "CD"
			      "cd"
		      when "CD-BD"
			      "cd_bd"
		      when "CSADP-BD"
			      "csadp_bd"
		      when "AGC"
		        "agc"
		      when "PE"
		        "pe"
			    else
			      "sessions"
		      end
		  end			
    end 
	  
end
