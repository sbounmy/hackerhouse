class IframesController < ApplicationController
  def show
    I18n.locale = :fr
    @house = House.find_by(slug_id: params[:id])
  end
  
  after_action :allow_iframe

  private

  def allow_iframe
    response.headers['X-Frame-Options'] = 'ALLOW-FROM https://hackerhouse.paris'
  end
end
