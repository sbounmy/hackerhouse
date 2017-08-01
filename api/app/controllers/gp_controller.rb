class GpController < ApplicationController
  def show
    @house = House.find_by(slug_id: params[:slug_id])
  end
end
