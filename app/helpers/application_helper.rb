module ApplicationHelper
  def coffee_script_tag(&block)
    content_tag(:script, CoffeeScript.compile(capture(&block)).html_safe, type: 'text/javascript')
  end
end
