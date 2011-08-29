class Notifier < ActionMailer::Base
  default from: configatron.site_name + " <USERNAME@gmail.com>" #CONF

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.register_validation.subject
  #
  def register_validation(user)
    @user = user
    
    @activation_link = configatron.site_url #TODO: Add user email validation to system

    mail to: @user.email, :subject => configatron.site_name + ' Registration'
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.password_change.subject
  #
  def password_change
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
