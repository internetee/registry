module WhoisStatusPopulate
  extend ActiveSupport::Concern

  def generate_json(record, domain_status:)
    h = HashWithIndifferentAccess.new(name: record.name, status: [domain_status])
    return h if record.json.blank?

    status_arr = (record.json['status'] ||= [])
    return record.json if status_arr.include? domain_status

    status_arr.push(domain_status)
    record.json['status'] = status_arr
    record.json
  end
end
