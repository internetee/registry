module ContactHelper
  def printable_street(street)
    street.to_s.gsub("\n", '<br>').html_safe
  end
end
