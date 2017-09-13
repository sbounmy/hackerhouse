module GpHelper
  def cents amount
    number_to_currency amount / 100, locale: 'fr', precision: 0
  end
end