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
end