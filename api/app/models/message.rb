class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  include Concerns::MongoidQuery

  # Fields
  field :check_in, type: Date
  field :check_out, type: Date
  field :body, type: String
  field :status,  type: String, default: 'pending'

  # Associations
  belongs_to :user
  belongs_to :house

  has_and_belongs_to_many :plus_ones, class_name: "User"
  has_and_belongs_to_many :minus_ones, class_name: "User"

  def self.queryable_scopes
    []
  end
end