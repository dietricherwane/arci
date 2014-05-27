class CategoriesController < ApplicationController

  before_filter :sign_out_disabled_users
  prepend_before_filter :authenticate_user!
  
  layout :layout_used
  
  def index
    @categories = Category.all.order("name").page(params[:page]).per(8)
    @namecss = @short_namecss = "row-form"
  end
  
  def create
    @name = params[:name]
    @short_code = params[:short_code]
    @error_messages = []
    @success_messages = []
    @categories = Category.all.order("name").page(params[:page]).per(8)
    
    if @name.blank? then @error_messages << "Veuillez entrer le nom de la catégorie à créer."; @namecss = "row-form error" else @namecss = "row-form" end
    if @short_code.blank? or @short_code.length != 3 then @error_messages << "L'abbréviation a une taille de 3 caractères."; @short_namecss = "row-form error" else @short_namecss = "row-form" end
    if !Category.find_by_name(@name).blank? or !Category.find_by_short_code(@short_code.upcase).blank?
      @error_messages << "Le nom du type de document ainsi que son abbréviation doivent être uniques"
    end
    
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
  
  def edit
    @namecss = "row-form"
    @category = Category.find_by_id(params[:category_id])
    if @category.blank?
      redirect_to :back, :notice => "Ce type de document n'existe pas"
    else
      @categories = Category.all.order("name ASC").page(params[:page]).per(8)
    end    
  end
  
  def update
    @name = params[:name].strip
    @error_messages = []
    @success_messages = []
    @categories = Category.all.order("name").page(params[:page]).per(8)
    @category = Category.find_by_id(params[:id])
    @namecss = "row-form"
    
    if @name.blank?
      @error_messages << "Veuillez entrer un de type de document"
      @namecss = "row-form error"
    end
    if !@category.blank? and @category.id != params[:id].to_i
      @error_messages << "Un type de document portant ce nom existe déjà"
      @namecss = "row-form error"
    end
    
    if @error_messages.blank?
      @category.update_attributes(:name => @name)
      @success_messages << "Le type de document #{@name} a été modifié."
    end   
    render :edit
  end
  
  def enable
	  enable_disable(params[:category_id], true, "activé")
	end
	
	def disable
	  enable_disable(params[:category_id], false, "désactivé")
	end
	
	def enable_disable(id, bool, status)
	  @category = Category.find_by_id(id)
	  @category.blank? ? false : @category.update_attributes(published: bool)
	  redirect_to "/categories", :notice => "Le type de document #{@category.name} a été #{status}."
	end
  
end
