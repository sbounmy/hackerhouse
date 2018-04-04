FactoryGirl.define do

  factory :message do
    check_in  { 1.month.from_now }
    check_out { 4.month.from_now }
    house
    user

    body "Salut, je suis un jeune entrepreneur de 25 ans :) je suis originaire de Lyon mais je suis sur Paris depuis bientôt 3 ans pour vivre la startup life à 200% ! Je suis le CTO de Pitch My Startup, un des événements phares de la scène startup parisienne. Tous les trimestres, on organise un événement de pitch de startups avec plus de 600 membres de l'écosystème startup (entrepreneurs, VC, etc). Notre but est vraiment de promouvoir l'entrepreneuriat et d'accompagner les startups dans la réussite de leur projet \o/ on est également en train de développer une web app permettant de créer des appels à projets de les gérer collaborativement, et donnant accès aux startups à une grande marketplace d'appels à projets. 
Je suis aussi dev web front end en freelance (c'est cool d'être entrepreneur mais c'est cool aussi de se mettre de l'argent de côté :) )"
  end

end
