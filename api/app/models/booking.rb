class Booking
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :check_in, type: Date
  field :check_out, type: Date
  field :message, type: String
  field :status,  type: String, default: 'pending'
  field :stripe_id, type: String #Subscription ID

  # Associations
  belongs_to :user
  belongs_to :house

  has_and_belongs_to_many :plus_ones, class_name: "User"
  has_and_belongs_to_many :minus_ones, class_name: "User"
end