module ApplicationHelper
  def flash_class(level)
    case level
    when :notice then "alert alert-info"
    when :success then "alert alert-success"
    when :error then "alert alert-error"
    when :alert then "alert alert-error"
    end
  end
  
  def fields_in_error_formating(field_name)
	  @information.errors[:"#{field_name}"].blank? ? 'row-form' : 'row-form error'
	end
	
	def go_back()
    link_to('Revenir en arrière', 'javascript:history.go(-1);', :class => 'cancel')
  end
end
