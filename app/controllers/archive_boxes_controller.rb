class ArchiveBoxesController < ApplicationController

  before_filter :sign_out_disabled_users
  prepend_before_filter :authenticate_user!
  
  layout :layout_used
  
  def index
    @archive_boxes = ArchiveBox.all.order("name")
    @archive_boxecss = "row-form"
  end
  
  def create
    @name = params[:name]
    @error_messages = []
    @success_messages = []
    @archive_boxes = ArchiveBox.all.order("name")
    
    if @name.blank? then @error_messages << "Veuillez entrer le nom de la boîte d'archives à créer."; @archive_boxecss = "row-form error" else @archive_boxecss = "row-form" end
    
    if @error_messages.blank?
      ArchiveBox.create(:name => @name.strip)
      @success_messages << "La boîte d'archives: #{@name.strip} a été créée."
    end   
    render :index
  end
end
