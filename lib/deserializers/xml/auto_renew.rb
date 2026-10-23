module Deserializers
  module Xml
    class AutoRenew
      URI = 'https://epp.tld.ee/schema/autoRenew-ee-1.0.xsd'.freeze

      class Error < StandardError
        attr_reader :code

        def initialize(code, message)
          @code = code
          super(message)
        end
      end

      def initialize(frame, command:)
        @frame = frame.is_a?(String) ? Nokogiri::XML(frame) : frame
        @command = command.to_s
      end

      def call
        nodes = @frame.xpath('//autoRenew:*', 'autoRenew' => URI)
        return if nodes.empty?

        blocks = nodes.select { |node| node.parent.namespace&.href != URI }
        invalid!('2001') unless blocks.size == 1
        block = blocks.first
        namespaces = {
          'epp' => 'https://epp.tld.ee/schema/epp-ee-1.0.xsd',
          'autoRenew' => URI,
        }
        expected = @frame.xpath("/epp:epp/epp:command/epp:extension/autoRenew:#{@command}", namespaces)
        invalid!('2001') unless expected.to_a == [block]
        commands = @frame.xpath("/epp:epp/epp:command/epp:#{@command}", namespaces)
        extensions = @frame.xpath('/epp:epp/epp:command/epp:extension', namespaces)
        invalid!('2001') unless commands.size == 1 && extensions.size == 1
        invalid!('2001') if block.attribute_nodes.any?
        children = block.element_children
        invalid!('2003') if children.empty?
        invalid!('2001') unless children.size == 1
        child = children.first
        invalid!('2001') unless child.namespace&.href == URI && child.element_children.empty?
        invalid!('2001') if block.children.any? { |node| node.text? && node.text.strip.present? }

        case child.name
        when 'enabled'
          invalid!('2001') if child.attribute_nodes.any?
          value = child.text.strip
          invalid!('2005') unless %w[true false 1 0].include?(value)
          { enabled: %w[true 1].include?(value) }
        when 'reverse'
          invalid!('2306') if @command == 'create'
          invalid!('2003') if child['cycleId'].blank?
          invalid!('2001') unless child.attribute_nodes.size == 1 &&
                                 child.attribute_nodes.first.name == 'cycleId' &&
                                 child.attribute_nodes.first.namespace.nil? && child.text.strip.empty?
          { reverse_cycle_id: child['cycleId'] }
        else
          invalid!('2001')
        end
      end

      private

      def invalid!(code)
        raise Error.new(code, I18n.t("epp.auto_renew.errors.#{code}"))
      end
    end
  end
end
