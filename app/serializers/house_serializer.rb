class HouseSerializer < ActiveModel::Serializer
  attributes  :name, :description, :slug_id, :slack_id,
                     :stripe_publishable_key, :stripe_id
end