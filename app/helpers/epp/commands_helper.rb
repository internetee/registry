module Epp::CommandsHelper
  def command_params_for type
    node_set = parsed_frame.css("epp command #{type} #{type}").children.select(&:element?)
    node_set.inject({}) {|hash, obj| hash[obj.name.to_sym] = obj.text;hash }
  end
end
