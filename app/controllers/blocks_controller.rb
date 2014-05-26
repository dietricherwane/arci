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
    
    if @error_messages.blank?
      @shaft = Shaft.find_by_id(@shaft_id)
      @shaft.blocks.create(:name => @block.strip)
      @success_messages << "Le bloc: #{@block.strip} a été ajoutée au puits: #{@shaft.name}."
    end    
    render "/shafts/index"
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
