class BookingsAPI < Grape::API

  resource :bookings do

    route_param :id do
      desc "Get a Booking"
      get do
        Booking.find(params[:id])
      end
    end

    params do
      requires :check_in,               type: Date,   desc: 'Check in date'
      requires :check_out,              type: Date,   desc: 'Check out date'

      requires :house_id,               type: String, desc: 'House id'
      requires :message,                type: String, desc: "Description"
    end
    post do
      declared_params[:user_id] = current_user.id
      Booking.new(declared_params).tap do |booking|
        authorize booking, :create?
        booking.save!
      end
    end
  end

end
