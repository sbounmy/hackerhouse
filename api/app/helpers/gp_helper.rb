module GpHelper
  def cents amount
    number_to_currency amount, locale: 'fr', precision: 0
  end
end