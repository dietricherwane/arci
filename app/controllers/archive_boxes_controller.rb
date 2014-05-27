class ArchiveBoxesController < ApplicationController

  before_filter :sign_out_disabled_users
  prepend_before_filter :authenticate_user!
  
  layout :layout_used
  
  def index
    @archive_boxes = ArchiveBox.all.order("name").page(params[:page]).per(8)
    @archive_boxecss = "row-form"
  end
  
  def create
    @name = params[:name]
    @error_messages = []
    @success_messages = []
    @archive_boxes = ArchiveBox.all.order("name").page(params[:page]).per(8)
    
    if @name.blank? then @error_messages << "Veuillez entrer le nom de la boîte d'archives à créer."; @archive_boxecss = "row-form error" else @archive_boxecss = "row-form" end
    
    if @error_messages.blank?
      ArchiveBox.create(:name => @name.strip)
      @success_messages << "La boîte d'archives: #{@name.strip} a été créée."
    end   
    render :index
  end
  
  def edit
    @namecss = "row-form"
    @archive_box = ArchiveBox.find_by_id(params[:archive_box_id])
    if @archive_box.blank?
      redirect_to :back, :notice => "Cette boîte d'archives n'existe pas"
    else
      @archive_boxes = ArchiveBox.all.order("name ASC").page(params[:page]).per(8)
    end    
  end
  
  def update
    @name = params[:name].strip
    @error_messages = []
    @success_messages = []
    @archive_boxes = ArchiveBox.all.order("name").page(params[:page]).per(8)
    @archive_box = ArchiveBox.find_by_id(params[:id])
    @namecss = "row-form"
    
    if @name.blank?
      @error_messages << "Veuillez entrer un nom de boîte d'archive"
      @namecss = "row-form error"
    end
    if !@archive_box.blank? and @archive_box.id != params[:id].to_i
      @error_messages << "Une boîte d'archive portant ce nom existe déjà"
      @namecss = "row-form error"
    end
    
    if @error_messages.blank?
      @archive_box.update_attributes(:name => @name)
      @success_messages << "La boîte d'archive #{@name} a été modifiée."
    end   
    render :edit
  end
  
  def enable
	  enable_disable(params[:archive_box_id], true, "activé")
	end
	
	def disable
	  enable_disable(params[:archive_box_id], false, "désactivé")
	end
	
	def enable_disable(id, bool, status)
	  @archive_box = ArchiveBox.find_by_id(id)
	  @archive_box.blank? ? false : @archive_box.update_attributes(published: bool)
	  redirect_to "/boites-darchives", :notice => "La boîte d'archives #{@archive_box.name} a été #{status}."
	end
  
end
