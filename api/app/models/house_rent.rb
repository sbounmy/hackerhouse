class HouseRent

  def initialize(house, date)
    @house = house
    @date = date
  end


  def users
  end

  def days_total
    @date.end_of_month.day
  end
  
  private

  def generate_calendar
    
  end
end