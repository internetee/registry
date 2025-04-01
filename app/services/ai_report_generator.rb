# app/services/ai_report_generator.rb
# require 'openai'

class AiReportGenerator
  def initialize(prompt, schema = nil)
    @prompt = prompt
    @schema = schema.presence || fetch_database_schema
    @client = OpenAI::Client.new
  end

  def generate
    system_prompt = <<~PROMPT
      You are an expert SQL developer. Your task is to create a readonly SQL query based on a user's request.
      Use the provided database schema to create an accurate SQL query. Do not create any write and delete queries.

      Database Schema:
      #{@schema}
    PROMPT

    Rails.logger.debug(system_prompt)

    user_prompt = "Create a report for: #{@prompt}. " \
      'Create parameters for the report if required according to schema.' \
      'Make sure parameter name is included in sql query with colon in front.' \
      "For default date value you can put #{Date.today.strftime('%Y-%m-%d')}."

    response = @client.chat(
      parameters: {
        model: ENV['openai_model'] || 'gpt-4o',
        response_format: {
          type: 'json_schema',
          json_schema: response_schema
        },
        messages: [
          { role: 'system', content: system_prompt },
          { role: 'user', content: user_prompt }
        ],
        temperature: ENV['openai_temperature'].to_f || 0.6
      }
    )

    finish_reason = response.dig('choices', 0, 'finish_reason')
    raise StandardError, 'Incomplete response' if finish_reason && finish_reason == 'length'

    refusal = response.dig('choices', 0, 'message', 'refusal')
    raise StandardError, refusal if refusal

    content = response.dig('choices', 0, 'message', 'content')
    raise StandardError, response.dig('error', 'message') || 'No response content' if content.nil?

    Rails.logger.info "AI response received: #{content}"

    { success: true, result: JSON.parse(content) }
  rescue StandardError => e
    Rails.logger.error("AI Report Generation Error: #{e.message}")
    { success: false, error: e.message }
  end

  private

  # rubocop:disable Metrics/MethodLength
  def response_schema
    {
      name: 'ai_response',
      strict: true,
      schema: {
        type: 'object',
        properties: {
          name: { type: 'string', description: 'A concise name for the report' },
          description: { type: 'string', description: 'A short detailed description of what the report shows' },
          sql_query: { type: 'string', description: 'The SQL query that fulfills the request' },
          parameters: {
            type: %w[array null],
            description: 'An array of parameter objects',
            items: {
              type: 'object',
              properties: {
                name: { type: 'string' },
                type: { type: 'string', description: 'The type of parameter string|date', enum: %w[string date] },
                default: { type: %w[string null], description: 'The default value (optional)' }
              },
              required: %w[name type default],
              additionalProperties: false
            }
          }
        },
        required: %w[name description sql_query parameters],
        additionalProperties: false
      }
    }
  end
  # rubocop:enable Metrics/MethodLength

  def fetch_database_schema
    # This is a simplified approach - you might want to enhance this
    # to provide more detailed schema information
    tables = ActiveRecord::Base.connection.tables
    schema = tables.map do |table|
      columns = ActiveRecord::Base.connection.columns(table)
      column_info = columns.map { |c| "#{c.name} (#{c.type})" }.join(', ')
      "Table: #{table} - Columns: #{column_info}"
    end

    schema.join('\n')
  end
end
