class BlocksController < ApplicationController
  
  before_filter :sign_out_disabled_users
  prepend_before_filter :authenticate_user!
  
  layout :layout_used

  def create
    @error_messages = []
    @success_messages = []
    @shaft_id = params[:post][:shaft_id]
    @block = params[:block_name]
    @shafts = Shaft.where("published IS NOT FALSE")
    @dropdown_shafts = Shaft.all.order("name")
    @shaft_namecss = @shaft_block_idcss = @block_namecss = "row-form"
    
    if @shaft_id.blank? then @error_messages << "Veuillez d'abord choisir un puits."; @shaft_block_idcss = "row-form error" end
    if @block.blank? then @error_messages << "Veuillez entrer le nom du bloc à créer."; @block_namecss = "row-form error" end
    
    if !Block.where("name = '#{@name}' AND shaft_id = #{@shaft_id}").blank?
      @error_messages << "Un bloc portant ce nom existe déjà dans ce puits."
    end
    
    if @error_messages.blank?
      @shaft = Shaft.find_by_id(@shaft_id)
      @shaft.blocks.create(:name => @block.strip)
      @success_messages << "Le bloc: #{@block.strip} a été ajoutée au puits: #{@shaft.name}."
    end    
    render "/shafts/index"
  end
  
  def edit
    @namecss = "row-form"
    @block = Block.find_by_id(params[:block_id])
    if @block.blank?
      redirect_to :back, :notice => "Ce bloc n'existe pas"
    else
      @shafts = Shaft.all.order("name ASC").page(params[:page]).per(8)
    end    
  end
  
  def update
    @name = params[:name].strip
    @error_messages = []
    @success_messages = []
    @shafts = Shaft.all.order("name ASC").page(params[:page]).per(8)
    @block = Block.find_by_id(params[:id])
    @existing_block = Block.find_by_name(@name)
    @namecss = "row-form"
    
    if @name.blank?
      @error_messages << "Veuillez entrer un nom de bloc"
      @namecss = "row-form error"
    end
    if !@existing_block.blank? and @existing_block.shaft_id == @block.id and @existing_block.id != params[:id].to_i
      @error_messages << "Un bloc portant ce nom existe déjà dans ce puits."
      @namecss = "row-form error"
    end
    
    if @error_messages.blank?
      @block.update_attributes(:name => @name)
      @success_messages << "Le bloc #{@name} a été modifié."
    end   
    render :edit
  end
  
  def enable
	  enable_disable(params[:block_id], true, "activé")
	end
	
	def disable
	  enable_disable(params[:block_id], false, "désactivé")
	end
	
	def enable_disable(id, bool, status)
	  @block = Shaft.find_by_id(id)
	  @block.blank? ? false : @block.update_attributes(published: bool)
	  redirect_to "/blocks", :notice => "Le bloc #{@block.name} a été #{status}."
	end
  
  def get_blocks
    @shaft_id = params.first.first
    @blocks_options = "<option>-Veuillez choisir un bloc-</option>"
    @blocks = Shaft.find_by_id(@shaft_id).blocks.where("published IS NOT FALSE")
    unless @blocks.blank?
      @blocks.each do |block|
        @blocks_options << "<option>#{block.name}</option>"
      end
    end
    render :text => @blocks_options
  end
end
