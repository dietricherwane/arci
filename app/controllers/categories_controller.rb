class CategoriesController < ApplicationController

  before_filter :sign_out_disabled_users
  prepend_before_filter :authenticate_user!
  
  layout :layout_used
  
  def index
    @categories = Category.all.order("name")
    @namecss = @short_namecss = "row-form"
  end
  
  def create
    @name = params[:name]
    @short_code = params[:short_code]
    @error_messages = []
    @success_messages = []
    @categories = Category.all.order("name")
    
    if @name.blank? then @error_messages << "Veuillez entrer le nom de la catégorie à créer."; @namecss = "row-form error" else @namecss = "row-form" end
    if @short_code.blank? or @short_code.length != 3 then @error_messages << "L'abbréviation a une taille de 3 caractères."; @short_namecss = "row-form error" else @short_namecss = "row-form" end
    
    params[:name] = @name.strip
    params[:short_code] = @short_code.strip.upcase
    
    if @error_messages.blank?
      Category.create(:name => @name.strip, :short_code => @short_code.strip.upcase)
      params[:name] = ""
      params[:short_code] = ""
      @success_messages << "Le type de document: #{@name.strip} en abbrégé #{@short_code.strip.upcase} a été créé."
    end   
    render :index
  end
  
end
