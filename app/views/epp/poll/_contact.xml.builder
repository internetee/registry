builder.resData do
  builder.tag!('contact:infData', 'xmlns:contact' => 'https://epp.tld.ee/schema/contact-ee-1.1.xsd') do
    builder.tag!('contact:id', contact.code)
    builder.tag!('contact:roid', contact.roid)

    contact.statuses.each do |status|
      builder.tag!('contact:status', s: status)
    end

    builder.tag!('contact:postalInfo', type: 'int') do
      builder.tag!('contact:name', contact.name)
      if can? :view_full_info, contact, @password
        builder.tag!('contact:org', contact.org_name) if contact.org_name.present?

        if address_processing
          builder.tag!('contact:addr') do
            builder.tag!('contact:street', contact.street)
            builder.tag!('contact:city', contact.city)
            builder.tag!('contact:sp', contact.state)
            builder.tag!('contact:pc', contact.zip)
            builder.tag!('contact:cc', contact.country_code)
          end
        end

      else
        builder.tag!('contact:org', 'No access')

        if address_processing
          builder.tag!('contact:addr') do
            builder.tag!('contact:street', 'No access')
            builder.tag!('contact:city', 'No access')
            builder.tag!('contact:sp', 'No access')
            builder.tag!('contact:pc', 'No access')
            builder.tag!('contact:cc', 'No access')
          end
        end

      end
    end

    if can? :view_full_info, contact, @password
      builder.tag!('contact:voice', contact.phone)
      builder.tag!('contact:fax', contact.fax) if contact.fax.present?
      builder.tag!('contact:email', contact.email)
    else
      builder.tag!('contact:voice', 'No access')
      builder.tag!('contact:fax', 'No access')
      builder.tag!('contact:email', 'No access')
    end

    builder.tag!('contact:clID', contact.registrar.try(:code))

    builder.tag!('contact:crID', contact.cr_id)
    builder.tag!('contact:crDate', contact.created_at.try(:iso8601))

    if contact.updated_at > contact.created_at
      upID = contact.updator.try(:registrar)
      upID = upID.code if upID.present? # Did updator return a kind of User that has a registrar?
      builder.tag!('contact:upID', upID) if upID.present? # optional upID
      builder.tag!('contact:upDate', contact.updated_at.try(:iso8601))
    end
    if can? :view_password, contact, @password
      builder.tag!('contact:authInfo') do
        builder.tag!('contact:pw', contact.auth_info)
      end
    else
      builder.tag!('contact:authInfo') do
        builder.tag!('contact:pw', 'No access')
      end
    end
  end
end