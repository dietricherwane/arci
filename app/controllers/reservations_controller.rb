class ReservationsController < ApplicationController
  before_filter :sign_out_disabled_users
  prepend_before_filter :authenticate_user!
  
  layout :layout_used
  
  def index   
    @books = Book.where("published IS NOT FALSE AND quantity_in_stock = 0").order("title")
    @termscss = "row-form"
  end
  
  def search_unavailable
    @terms = params[:terms]
    @sql = ""
    @results = ""
    
    if @terms.blank?
      @books = Book.where("published IS NOT FALSE AND quantity_in_stock = 0").order("title")
    else
      @terms = @terms.strip.split
      
      if Book.where("#{sql_for_books(@terms)}").blank?
        @sql = "" #sql_for_categories(@terms).sub(/^AND/, '')
      else
        @sql = sql_for_books(@terms) << sql_for_categories(@terms)
      end
      
      @books = Book.where("#{@sql}").order("title")
      if @sql.blank?
        @books = nil
      end
    end
      
    respond_to do |format|           
      format.js do 
			  render 'search_results', :locals => { :books => @books, :sql => @sql } 
		  end
		end
  end
  
  def sql_for_books(terms)
    @sql_for_books = "(("
    terms.each do |term|
      @sql_for_books << "( title ILIKE "+"'%"+term+"%' OR code ILIKE "+"'%"+term+"%') AND"
    end
    @sql_for_books = @sql_for_books.sub(/AND$/, '') << ") AND published IS NOT FALSE AND quantity_in_stock = 0)"
  end
  
  def sql_for_categories(terms)
    @sql_for_categories = "(("
    terms.each do |term|
      @sql_for_categories << " name ILIKE "+"'%"+term+"%' OR"
    end
    @sql_for_categories = @sql_for_categories.sub(/OR$/, '') << ") AND published IS NOT FALSE)"
    @categories = Category.where("#{@sql_for_categories}")
    @sql_for_categories = " category_id IN ("
    if @categories.blank?
      @sql_for_categories = ""
    else
      @categories.each do |category|
        @sql_for_categories << "#{category.id},"
      end
      @sql_for_categories = "AND " << @sql_for_categories.sub(/,$/, '') << ")"
    end
  end   
  
  def create   
    @error = false  
    if params[:books_ids].blank?
      @books_ids = params[:books_ids] 
      @message = "<div class = 'alert alert-error'>Veuillez choisir au moins un document.</div>"
    else
      @count = Reservation.where("user_id = #{current_user.id} AND status IS NULL").count
      if @count == 5
        @message = "<div class = 'alert alert-error'>Vous ne pouvez réserver que 5 documents.</div>"
      else
        @books_ids = params[:books_ids].split(",")
        
        @books_ids.each do |id|
          if @count < 5
            Reservation.create(user_id: current_user.id, book_id: id)
          else
            @error = true    
          end
          @count += 1
        end
        if @error
          @message = "<div class = 'alert alert-error'>Vous ne pouvez réserver que 5 documents.</div>"
        else
          @message = "<div class = 'alert alert-success'>Votre réservation a bien été enregistrée.</div>"
        end
      end    
    end
    render :text => @message
  end 
  
  def list
    @reservations = current_user.reservations.order("created_at DESC").page(params[:page]).per(8)
  end
  
end
