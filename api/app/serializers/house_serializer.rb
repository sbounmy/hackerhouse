class HouseSerializer < ActiveModel::Serializer
  attributes  :id, :name, :description, :slug_id, :slack_id,
                     :stripe_publishable_key, :stripe_id, :user_ids,
                     :default_price
end