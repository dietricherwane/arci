class ConsultantsController < ApplicationController

  before_filter :sign_out_disabled_users
  prepend_before_filter :authenticate_user!
  
  layout :layout_used
  
  def index
    @consultants = Consultant.all.order("name")
    @namecss = "row-form"
  end
  
  def create
    @name = params[:name]
    @error_messages = []
    @success_messages = []
    @consultants = Consultant.all.order("name")
    
    if @name.blank? then @error_messages << "Veuillez entrer le nom du consultant à créer."; @namecss = "row-form error" else @namecss = "row-form" end
    
    if @error_messages.blank?
      Consultant.create(:name => @name.strip)
      @success_messages << "Le consultant: #{@name.strip} a été créé."
      params[:name] = ""
    end   
    render :index
  end
  
  def edit
    @namecss = "row-form"
    @consultant = Consultant.find_by_id(params[:consultant_id])
    if @consultant.blank?
      redirect_to :back, :notice => "Cet organe d'étude n'existe pas"
    else
      @consultants = Consultant.all.order("name ASC")
    end    
  end
  
  def update
    @name = params[:name].strip
    @error_messages = []
    @success_messages = []
    @consultants = Consultant.all.order("name")
    @consultant = Consultant.find_by_id(params[:id])
    @namecss = "row-form"
    
    if @name.blank?
      @error_messages << "Veuillez entrer un nom d'organe d'étude"
      @namecss = "row-form error"
    end
    if !@consultant.blank? and @consultant.id != params[:id].to_i
      @error_messages << "Un organe d'étude portant ce nom existe déjà"
      @namecss = "row-form error"
    end
    
    if @error_messages.blank?
      @consultant.update_attributes(:name => @name)
      @success_messages << "L'organe d'étude #{@name} a été modifié."
    end   
    render :edit
  end
  
  def enable
	  enable_disable(params[:consultant_id], true, "activé")
	end
	
	def disable
	  enable_disable(params[:consultant_id], false, "désactivé")
	end
	
	def enable_disable(id, bool, status)
	  @consultant = Consultant.find_by_id(id)
	  @consultant.blank? ? false : @consultant.update_attributes(published: bool)
	  redirect_to "/consultants", :notice => "La boîte d'archives #{@consultant.name} a été #{status}."
	end
end
