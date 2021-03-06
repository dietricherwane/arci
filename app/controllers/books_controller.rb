class BooksController < ApplicationController
  require 'barby'
  require 'barby/barcode/code_128'
  require 'barby/outputter/png_outputter'
  
  before_filter :sign_out_disabled_users
  prepend_before_filter :authenticate_user!
  
  layout :layout_used
  
  def codes
    @categories = Category.where("published IS NOT FALSE").order("name")
    @shafts = Shaft.where("published IS NOT FALSE").order("name")
    @consultants = Consultant.where("published IS NOT FALSE").order("name")
    @archives_boxes = ArchiveBox.where("published IS NOT FALSE").order("name")
    @books = Book.all.order("title")
    @categoriescss = @titlecss = @shaftscss = @blockcss = @publication_datecss = @consultantscss = @archive_boxescss = @total_quantitycss = @descriptioncss = @geographic_positioncss = "row-form"
  end

  def create
    @categories = Category.where("published IS NOT FALSE").order("name")
    @shafts = Shaft.where("published IS NOT FALSE").order("name")
    @consultants = Consultant.where("published IS NOT FALSE").order("name")
    @archives_boxes = ArchiveBox.where("published IS NOT FALSE").order("name")
    @books = Book.all.order("title")
    @category_id = params[:post][:category_id]
    @title = params[:title]
    @description = params[:description]
    @shaft_id = params[:post][:shaft_id]
    @block = params[:block]
    @publication_date = params[:publication_date]
    @publication_date_status = Date.parse(@publication_date) rescue nil
    if !@publication_date_status.blank?
      (@publication_date_status < Date.today) ? false : @publication_date_status = nil  
    end
    @consultant_id = params[:post][:consultant_id]
    @archive_box_id = params[:post][:archive_box_id]
    @geographic_position = params[:geographic_position]
    @total_quantity = params[:total_quantity]
    @error_messages = []
    @success_messages = []
    
    params[:category_id] = @category_id.to_i
    params[:shaft_id] = @shaft_id.to_i
    params[:consultant_id] = @consultant_id.to_i
    params[:archive_box_id] = @archive_box_id.to_i
    params[:title] = @title
    params[:description] = @description
    params[:publication_date] = @publication_date
    params[:geographic_position] = @geographic_position
    params[:total_quantity] = @total_quantity
    
    if @category_id.blank? then @error_messages << "Veuillez choisir un type de document"; @categoriescss = "row-form error" else @categoriescss = "row-form" end
    if @title.blank? then @error_messages << "Veuillez entrer le titre du document"; @titlecss = "row-form error" else @titlecss = "row-form" end
    if @geographic_position.blank? then @error_messages << "Veuillez entrer la position géographique du document"; @geographic_positioncss = "row-form error" else @geographic_positioncss = "row-form" end
    if @description.blank? then @error_messages << "Veuillez entrer la description du document"; @descriptioncss = "row-form error" else @descriptioncss = "row-form" end
    if @shaft_id.blank? then @error_messages << "Veuillez choisir un puits"; @shaftscss = "row-form error" else @shaftscss = "row-form" end
    if (@block.blank? or @block.eql?("-Veuillez choisir un bloc-")) then @error_messages << "Veuillez choisir un bloc"; @blockcss = "row-form error" else @blockcss = "row-form" end
    if @publication_date_status.blank? then @error_messages << "Veuillez entrer une date de publication valide"; @publication_datecss = "row-form error" else @publication_datecss = "row-form" end
    if @consultant_id.blank? then @error_messages << "Veuillez choisir un organe d'étude"; @consultantscss = "row-form error" else @consultantscss = "row-form" end
    if @archive_box_id.blank? then @error_messages << "Veuillez choisir une boîte d'archives"; @archive_boxescss = "row-form error" else @archive_boxescss = "row-form" end
    if (!@total_quantity.blank? and !not_a_number?(@total_quantity) and @total_quantity.to_i > 0)  then @total_quantitycss = "row-form" else @error_messages << "La quantité est un nombre supérieur à 0"; @total_quantitycss = "row-form error" end
    
    params[:shaft_id] = nil
    
    if @error_messages.blank?
      @code = "#{Category.find_by_id(@category_id).short_code}~#{@title.strip}~#{Shaft.find_by_id(@shaft_id).name}~#{@block}~#{DateTime.parse(@publication_date).strftime("%d-%m-%y")}~#{Consultant.find_by_id(@consultant_id).name}~#{ArchiveBox.find_by_id(@archive_box_id).name}"
      if Book.find_by_code(@code).blank?
        Book.create(code: @code, title: @title.strip, description: @description.strip, total_quantity: @total_quantity.to_i, quantity_in_stock: @total_quantity.to_i, category_id: @category_id, block_id: Block.find_by_name(@block).id, consultant_id: @consultant_id, archive_box_id: @archive_box_id, geographic_position: @geographic_position, publication_date: @publication_date_status)
        @success_messages << "Le document possédant le code: #{@code} a été créé en #{@total_quantity.strip} exemplaire#{(@total_quantity.to_i > 1) ? 's' : ''}"
      else
        @error_messages << "Ce document existe déjà"
      end
    end
    
    render :codes
  end
  
  def send_request
    @books = Book.where("published IS NOT FALSE AND quantity_in_stock > 0").order("title")
    @termscss = "row-form"
  end
  
  def process_request       
    @error = false  
    if params[:books_ids].blank?
      @books_ids = params[:books_ids] 
      @message = "<div class = 'alert alert-error'>Veuillez choisir au moins un document.</div>"
    else
      @error_message = "<div class = 'alert alert-error'>Les documents suivants ne sont plus disponibles; néanmoins, vous pouvez les réserver:<br />"
      @books_ids = params[:books_ids].split(",")
      @demand = Demand.create(user_id: current_user.id, on_hold: true)
      @books_array = []
      
      @books_ids.each do |id|
        @book = Book.find_by_id(id)
        if @book.quantity_in_stock > 0
          @book.update_attributes(quantity_in_stock: @book.quantity_in_stock - 1)
          @demand.books << @book
          @books_array << "#{@book.title} || #{@book.code}"
          ActiveRecord::Base.connection.execute("UPDATE books_demands SET on_hold = TRUE, user_id = #{current_user.id} WHERE demand_id = #{@demand.id} AND book_id = #{@book.id}")
        else
          @error = true
          @error_message  << "[#{@book.category.name}] #{@book.title}<br />"
        end
      end
      @error_message << "</div>"
      @message = "<div class = 'alert alert-success'>Votre demande a bien été envoyée.</div>"
      
      # Envoi d'email de notification
      Thread.new do
        @csadp = User.where("profile_id = #{Profile.find_by_shortcut('CSADP-BD').id} AND published IS NOT FALSE")
        if !@csadp.blank?
          @csadp = @csadp.map { |user| user.email }
          Notifier.send_request(current_user.full_name, current_user.show_qualification, @csadp, @books_array).deliver
          if (ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?)
            ActiveRecord::Base.connection.close
          end
        end
      end    
      
      if @error
        @message = @error_message
      end
      if @demand.books.blank?
        @demand.destroy
      end
    end
    render :text => @message
  end
  
  def search_all_books
    @terms = params[:terms]
    @sql = ""
    @results = ""
    
    if @terms.blank?
      @books = Book.all.order("title")
    else
      @terms = @terms.strip.split
      
      if Book.where("#{sql_for_all_books(@terms)}").blank?
        @sql = "" #sql_for_categories(@terms).sub(/^AND/, '')
      else
        @sql = sql_for_all_books(@terms) << sql_for_categories(@terms)
      end
      
      @books = Book.where("#{@sql}").order("title")
      if @sql.blank?
        @books = nil
      end
    end
    unless @books.blank?
      @books = @books.page(params[:page]).per(8)
    end
  end
  
  def sql_for_all_books(terms)
    @sql_for_books = "(("
    terms.each do |term|
      @sql_for_books << "( title ILIKE "+"'%"+term+"%' OR code ILIKE "+"'%"+term+"%') AND"
    end
    @sql_for_books = @sql_for_books.sub(/AND$/, '') << "))"
  end
  
  def search
    @terms = params[:terms]
    @sql = ""
    @results = ""
    
    if @terms.blank?
      @books = Book.where("published IS NOT FALSE AND quantity_in_stock > 0").order("title")
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
    @sql_for_books = @sql_for_books.sub(/AND$/, '') << ") AND published IS NOT FALSE AND quantity_in_stock > 0)"
  end
  
  def sql_for_categories(terms)
    @sql_for_categories = "(("
    terms.each do |term|
      @sql_for_categories << " name ILIKE "+"'%"+term+"%' OR"
    end
    #@sql_for_categories = @sql_for_categories.sub(/OR$/, '') << "))"
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
  
  def list
    @categories = Category.order("name ASC")
  end
  
  def view_only
    @book = Book.find_by_id(params[:id])
    @file_name = "compressed.tracemonkey-pldi-09.pdf"
    @close_window = false
    
    if !File.file?("#{Rails.root}/public/book/xrdEBJeKNm7CNnMadTXCijfiq938C7aK94d1Y_1ltFhqfJo/GpEVv55FRiJ5Zj5MayShBXTWqNw/#{@file_name}")
      @close_window = true
    end
    render :layout => false
  end
  
  def list_books_per_category
    @category = Category.find_by_id(params[:category_id])
    if @category.blank?
      redirect_to :back
    else
      @books = @category.books.page(params[:page]).per(8)      
    end
  end
  
  def generate_barcode(code)
    @uri = URI.escape(code) + '.png'
    @fname = Rails.root + '/public/barcodes/' + @uri
    if ! File.exists?(@fname)
      @barcode = Barby::Code128B.new(@uri)
    end
    File.open("#{Rails.root}/public/barcodes/#{@uri}", 'w') do |f|
      f.write @barcode.to_png
    end
    @uri
  end
  
  def download_barcode
    unless params[:code].blank?
      @filename = generate_barcode(params[:code])
      send_file("#{Rails.root}/public/barcodes/#{@filename}",
        filename: "#{URI.unescape(@filename)}",
        type: "image/png"
      )
    end
  end
  
  def enable_book
	  enable_disable_book(params[:book_id], true, "activé")
	end
	
	def disable_book
	  enable_disable_book(params[:book_id], false, "désactivé")
	end
	
	def enable_disable_book(id, bool, status)
	  @status = status
	  @book = Book.find_by_id(id)
	  @book.blank? ? false : @book.update_attributes(published: bool)	 
	  redirect_to :back, :notice => "Le document #{@book.title} avec pour code: #{@book.code} a été #{@status}." 
	end
	
	def edit
	  @book = Book.find_by_id(params[:book_id])
	  @categories = Category.where("published IS NOT FALSE").order("name")
    @shafts = Shaft.where("published IS NOT FALSE").order("name")
    @consultants = Consultant.where("published IS NOT FALSE").order("name")
    @archives_boxes = ArchiveBox.where("published IS NOT FALSE").order("name")
    @books = Book.all.order("title")
    @categoriescss = @titlecss = @shaftscss = @blockcss = @publication_datecss = @consultantscss = @archive_boxescss = @total_quantitycss = @descriptioncss = @geographic_positioncss = "row-form"
	end
	
	def update
	  @book = Book.find_by_id(params[:book_id])
	  @categories = Category.where("published IS NOT FALSE").order("name")
    @shafts = Shaft.where("published IS NOT FALSE").order("name")
    @consultants = Consultant.where("published IS NOT FALSE").order("name")
    @archives_boxes = ArchiveBox.where("published IS NOT FALSE").order("name")
    @books = Book.all.order("title")
    @category_id = params[:post][:category_id]
    @title = params[:title]
    @description = params[:description]
    @shaft_id = params[:post][:shaft_id]
    @block = params[:block]
    @publication_date = params[:publication_date]
    @publication_date_status = Date.parse(@publication_date) rescue nil
    @consultant_id = params[:post][:consultant_id]
    @archive_box_id = params[:post][:archive_box_id]
    @geographic_position = params[:geographic_position]
    @total_quantity = params[:total_quantity]
    @error_messages = []
    @success_messages = []
    
    params[:category_id] = @category_id.to_i
    params[:shaft_id] = @shaft_id.to_i
    params[:consultant_id] = @consultant_id.to_i
    params[:archive_box_id] = @archive_box_id.to_i
    params[:title] = @title
    params[:description] = @description
    params[:publication_date] = @publication_date
    params[:geographic_position] = @geographic_position
    params[:total_quantity] = @total_quantity
    
    if @category_id.blank? then @error_messages << "Veuillez choisir un type de document"; @categoriescss = "row-form error" else @categoriescss = "row-form" end
    if @title.blank? then @error_messages << "Veuillez entrer le titre du document"; @titlecss = "row-form error" else @titlecss = "row-form" end
    if @geographic_position.blank? then @error_messages << "Veuillez entrer la position géographique du document"; @geographic_positioncss = "row-form error" else @geographic_positioncss = "row-form" end
    if @description.blank? then @error_messages << "Veuillez entrer la description du document"; @descriptioncss = "row-form error" else @descriptioncss = "row-form" end
    #if @shaft_id.blank? then @error_messages << "Veuillez choisir un puits"; @shaftscss = "row-form error" else @shaftscss = "row-form" end
    if @publication_date_status.blank? then @error_messages << "Veuillez entrer une date de publication valide"; @publication_datecss = "row-form error" else @publication_datecss = "row-form" end
    if @consultant_id.blank? then @error_messages << "Veuillez choisir un organe d'étude"; @consultantscss = "row-form error" else @consultantscss = "row-form" end
    if @archive_box_id.blank? then @error_messages << "Veuillez choisir une boîte d'archives"; @archive_boxescss = "row-form error" else @archive_boxescss = "row-form" end
    if (!@total_quantity.blank? and !not_a_number?(@total_quantity) and @total_quantity.to_i > 0)  then @total_quantitycss = "row-form" else @error_messages << "La quantité est un nombre supérieur à 0"; @total_quantitycss = "row-form error" end
    
    if @error_messages.blank?
      if @total_quantity.to_i == @book.total_quantity
      
      else
        if @total_quantity.to_i > @book.total_quantity
          @diff = @total_quantity.to_i - @book.total_quantity
          @total_quantity = @total_quantity.to_i
          @quantity_in_stock = @book.quantity_in_stock + @diff
          # si le livre a été réservé, on crée une demande
          reserve_book(@book)
        else
          @diff = @book.total_quantity - @total_quantity.to_i
          if (@book.quantity_in_stock - @diff) < 0
            @error_messages << "Le nombre de documents en stock ne peut pas être inférieur à 0"
          else
            @total_quantity = @total_quantity.to_i
            @quantity_in_stock = @book.quantity_in_stock - @diff
          end
        end
      end
    end
    
    if @error_messages.blank?
      
      if (@block.blank? or @block.eql?("-Veuillez choisir un bloc-"))
        @code = "#{Category.find_by_id(@category_id).short_code}~#{@title.strip}~#{Shaft.find_by_id(@shaft_id).name}~#{Block.find_by_id(@book.block_id).name}~#{DateTime.parse(@publication_date).strftime("%d-%m-%y")}~#{Consultant.find_by_id(@consultant_id).name}~#{ArchiveBox.find_by_id(@archive_box_id).name}"
        @book.update_attributes(code: @code, title: @title.strip, description: @description.strip, total_quantity: @total_quantity, quantity_in_stock: @quantity_in_stock, category_id: @category_id, consultant_id: @consultant_id, archive_box_id: @archive_box_id, geographic_position: @geographic_position, publication_date: @publication_date_status)
      else
        @code = "#{Category.find_by_id(@category_id).short_code}~#{@title.strip}~#{Shaft.find_by_id(@shaft_id).name}~#{@block}~#{DateTime.parse(@publication_date).strftime("%d-%m-%y")}~#{Consultant.find_by_id(@consultant_id).name}~#{ArchiveBox.find_by_id(@archive_box_id).name}"
        @book.update_attributes(code: @code, title: @title.strip, description: @description.strip, total_quantity: @total_quantity, quantity_in_stock: @quantity_in_stock, category_id: @category_id, block_id: Block.find_by_name(@block).id, consultant_id: @consultant_id, archive_box_id: @archive_box_id, geographic_position: @geographic_position, publication_date: @publication_date_status)
      end
      @success_messages << "Les informations concernant le document ont été modifiées."
    end
    
    render :edit
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
  
  def history
    
    @book = Book.find_by_id(params[:book_id])
    if @book.blank?
      redirect_to list_books_path, :notice => "Ce document n'existe pas."
    else
      @book_demands = ActiveRecord::Base.connection.execute("SELECT * FROM books_demands WHERE book_id = #{params[:book_id]}")#.page(params[:page]).per(8)
    end
  end
  
end
