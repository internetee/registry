module Epp::CommandsHelper
  def command_params
    node_set = parsed_frame.css('epp command create create').children.select(&:element?)
    node_set.inject({}) {|hash, obj| hash[obj.name.to_sym] = obj.text;hash }
  end
end
