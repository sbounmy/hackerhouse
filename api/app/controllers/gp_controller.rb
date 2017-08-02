class GpController < ApplicationController
  def show
    @house = House.find_by(slug_id: params[:slug_id])
  end

  def pricing
    @house = House.find_by(slug_id: params[:slug_id])
  end
  
  after_action :allow_iframe, on: :pricing

  private

  def allow_iframe
    response.headers['X-Frame-Options'] = 'ALLOW-FROM https://hackerhouse.paris'
  end
end
