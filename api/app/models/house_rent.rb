class HouseRent

  def initialize(house, date)
    @house = house
    @date = date
  end


  def users
    []
  end

  def days_total
    @date.end_of_month.day
  end
  
  def amount_per_day
    @house.amount / (@house.max_users * days_total)
  end

  private

  def generate_calendar
    
  end
end