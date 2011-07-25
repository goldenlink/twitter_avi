module ApplicationHelper

  #  Return a per page basis title: generate a base title and adds if available the page title
  def title
    base_title = "Ruby on Rails Tutorial Sample App"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end

end
