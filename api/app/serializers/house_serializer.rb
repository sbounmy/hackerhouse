class HouseSerializer < ActiveModel::Serializer
  attributes  :id, :name, :description, :slug_id, :slack_id,
                     :stripe_publishable_key, :stripe_id, :user_ids

  attributes :address, :city, :zip_code, :active_users, :max_users

  attribute :pantry_budget, if: :current_user?
  attribute :pantry_description, if: :current_user?
  attribute :pantry_login, if: :current_user?
  attribute :pantry_password, if: :current_user?
  attribute :pantry_url, if: :current_user?
  attribute :pantry_name, if: :current_user?

  def current_user?
    !!scope.current_user.id && object.user_ids.include?(scope.current_user.id)
  end

  def active_users
    object.users.active.count
  end
end