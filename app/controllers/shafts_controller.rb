class ShaftsController < ApplicationController
  
  before_filter :sign_out_disabled_users
  prepend_before_filter :authenticate_user!
  
  layout :layout_used

  def index
    @shafts = Shaft.where("published IS NOT FALSE")
    @dropdown_shafts = Shaft.all.order("name")
    @shaft_namecss = @shaft_block_idcss = @block_namecss = "row-form"
  end
  
  def create
    @shaft_name = params[:shaft_name]
    @shaft_block_idcss = @block_namecss = "row-form"
    @error_messages = []
    @success_messages = []
    @shafts = Shaft.where("published IS NOT FALSE")
    @dropdown_shafts = Shaft.all.order("name")
    
    if @shaft_name.blank? then @error_messages << "Veuillez entrer le nom du puits à créer."; @shaft_namecss = "row-form error" else @shaft_namecss = "row-form" end
    
    if @error_messages.blank?
      Shaft.create(:name => @shaft_name.strip)
      @success_messages << "Le puits #{@shaft_name.strip} a été créé."
    end   
    render :index
  end
end
