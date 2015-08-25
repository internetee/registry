class MailTemplate < ActiveRecord::Base

  validates :name, :subject, :from, :body, :text_body, presence: true

  def to_html(body)
    template = Erubis::Eruby.new(content, escape: true)
    template_result = template.result(context)
    Sanitize.clean(RDiscount.new(template_result).to_html.encode('UTF-8', undef: :replace), Sanitize::Config::RELAXED)
  end
end
