module GpHelper
  def cents amount
    number_to_currency amount, locale: 'fr', precision: 0
  end

  def link_to_contract house
    if house.commercial
      link_to("Conditions Générales d'Utilisation", "https://drive.google.com/file/d/1HNevyiyHVLJbmWfTbtNy-pN28BzZHWCE/view?usp=sharing",
      target: "_blank")
    else
      link_to("Contrat de location meublée", "https://drive.google.com/file/d/1CDi6qqzXKv5D9ONRTwKPliy2O9-5ChaN/view",
      target: "_blank")
    end
  end
end