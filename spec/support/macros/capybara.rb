module CapybaraViewMacros
  def page
    Capybara::Node::Simple.new(rendered)
  end
end
