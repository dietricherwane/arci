class ShaftsController < ApplicationController
  
  before_filter :sign_out_disabled_users
  prepend_before_filter :authenticate_user!
  
  layout :layout_used

  def index
    @shafts = Shaft.all.page(params[:page]).per(8)
    @dropdown_shafts = Shaft.all.order("name")
    @shaft_namecss = @shaft_block_idcss = @block_namecss = "row-form"
  end
  
  def create
    @shaft_name = params[:shaft_name]
    @shaft_block_idcss = @block_namecss = "row-form"
    @error_messages = []
    @success_messages = []
    @shafts = Shaft.all.page(params[:page]).per(8)
    @dropdown_shafts = Shaft.all.order("name")
    
    if @shaft_name.blank? then @error_messages << "Veuillez entrer le nom du puits à créer."; @shaft_namecss = "row-form error" else @shaft_namecss = "row-form" end
    
    if @error_messages.blank?
      Shaft.create(:name => @shaft_name.strip)
      @success_messages << "Le puits #{@shaft_name.strip} a été créé."
    end   
    render :index
  end
  
  def edit
    @namecss = "row-form"
    @shaft = Shaft.find_by_id(params[:shaft_id])
    if @shaft.blank?
      redirect_to :back, :notice => "Ce puits n'existe pas"
    else
      @shafts = Shaft.all.order("name ASC").page(params[:page]).per(8)
    end    
  end
  
  def update
    @name = params[:name].strip
    @error_messages = []
    @success_messages = []
    @shafts = Shaft.all.order("name").page(params[:page]).per(8)
    @shaft = Shaft.find_by_id(params[:id])
    @existing_shaft = Shaft.find_by_name(@name)
    @namecss = "row-form"
    
    if @name.blank?
      @error_messages << "Veuillez entrer un nom de puits"
      @namecss = "row-form error"
    end
    if !@existing_shaft.blank? and @existing_shaft.id.to_s != params[:id]
      @error_messages << "Un puits portant ce nom existe déjà"
      @namecss = "row-form error"
    end
    
    if @error_messages.blank?
      @shaft.update_attributes(:name => @name)
      @success_messages << "Le puits #{@name} a été modifié."
    end   
    render :edit
  end
  
  def enable
	  enable_disable(params[:shaft_id], true, "activé")
	end
	
	def disable
	  enable_disable(params[:shaft_id], false, "désactivé")
	end
	
	def enable_disable(id, bool, status)
	  @shaft = Shaft.find_by_id(id)
	  @shaft.blank? ? false : @shaft.update_attributes(published: bool)
	  redirect_to "/shafts", :notice => "Le puits #{@shaft.name} a été #{status}."
	end
end
