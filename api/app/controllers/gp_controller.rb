class GpController < ApplicationController
  def show
    I18n.locale = :fr
    @house = House.find_by(slug_id: params[:slug_id])
    render 'show2' if @house.v2?
  end

  def pricing
    I18n.locale = :fr
    @house = House.find_by(slug_id: params[:slug_id])
  end
  
  after_action :allow_iframe, on: :pricing

  private

  def allow_iframe
    response.headers['X-Frame-Options'] = 'ALLOW-FROM https://hackerhouse.paris'
  end
end