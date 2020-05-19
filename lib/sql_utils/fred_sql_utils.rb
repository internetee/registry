module FredSqlUtils
  DATABASE = ActiveRecord::Base.configurations['fred']

  def with_another_db(another_db_config)
    original_connection = ActiveRecord::Base.remove_connection
    ActiveRecord::Base.establish_connection(another_db_config)
    yield
  ensure
    ActiveRecord::Base.establish_connection(original_connection)
  end

  # rubocop:disable Rubocop/MethodLength
  def result_entries(sql:, bind: {})
    bindings = []
    bind_index = 1

    unless bind.empty?
      bind.each do |key, value|
        sql.gsub!(/(?<!:):#{key}(?=\b)/, "$#{bind_index}")
        bind_index += 1

        bindings << [nil, value]
      end
    end

    result = with_another_db(DATABASE) do
      ActiveRecord::Base.connection.exec_query(sql, 'SQL', bindings).map(&:symbolize_keys)
    end
    result.map do |v|
      next if v.nil?

      v.each do |key, val|
        v[key] = json_to_hash(val)
      end
    end
  end
  # rubocop:enable Rubocop/MethodLength

  def json_to_hash(json)
    JSON.parse(json, symbolize_names: true)
  rescue JSON::ParserError, TypeError
    json
  end
end
