class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'

  around_action :in_fr

  private

  def from(name)
    Mail::Address.new('julie@hackerhouse.paris').tap do |f|
      f.display_name = "#{name} (HackerHouse)"
    end
  end

  def in_fr
    I18n.with_locale :fr do
      yield
    end
  end

end
