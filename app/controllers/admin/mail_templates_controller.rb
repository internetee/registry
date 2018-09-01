module Admin
  class MailTemplatesController < BaseController
    load_and_authorize_resource

    def index
      @q = MailTemplate.search(params[:q])
      @mail_templates = @q.result.page(params[:page])
    end

    def new
      @mail_tempalte = MailTemplate.new
    end

    def show
      @mail_template = MailTemplate.find(params[:id])
      @subject = Liquid::Template.parse(@mail_template.subject).render.html_safe
      @html_body = Liquid::Template.parse(@mail_template.body).render.html_safe
      @text_body = Liquid::Template.parse(@mail_template.text_body).render.html_safe
    end

    def edit
      @mail_template = MailTemplate.find(params[:id])
    end

    def create
      @mail_template = MailTemplate.new(mail_template_params)

      if @mail_template.save
        redirect_to [:admin, @mail_template]
      else
        flash.now[:alert] = I18n.t(:failure)
        render 'new'
      end
    end

    def update
      @mail_template = MailTemplate.find(params[:id])

      if @mail_template.update_attributes(mail_template_params)
        redirect_to [:admin, @mail_template]
      else
        flash.now[:alert] = I18n.t(:failure)
        render 'edit'
      end
    end

    def destroy
      @mail_template = MailTemplate.find(params[:id])
      if @mail_template.destroy
        redirect_to admin_mail_templates_path, notice: t(:deleted)
      else
        flash.now[:alert] = I18n.t(:failure)
        render 'show'
      end
    end

    private

    def mail_template_params
      params.require(:mail_template).permit(:name, :subject, :from, :bcc, :cc, :body, :text_body)
    end
  end
end
