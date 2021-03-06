class Balance
  include ActiveModel::Serializers::JSON

  attr_accessor :house, :date

  def initialize(house, date)
    @house = house
    @date = date
    generate_calendar
  end

  def users
    balance_amount
  end

  def days_total
    @date.end_of_month.day
  end

  def amount_per_day
    @house.amount / (@house.max_users * days_total)
  end

  private

  def find_users
    User.customer.staying_on(@date, @house)
  end

  def generate_calendar
    @calendar = Array.new(find_users.count) { Array.new(days_total + 1) {1} }
    find_users.each_with_index do |user, i|
      @calendar[i][0] = user

      #someone leave during the month
      if not (user.check_in..user.check_out).cover? @date.end_of_month
        @calendar[i].fill(0, user.check_out.day)
      end
      #someone arrive during the month
      if [user.check_in.year, user.check_in.month] === [@date.year, @date.month]
        @calendar[i].fill(0, 1, user.check_in.day - 1)
      end
    end
    @calendar
  end

  def nb_per_day
    @nb_per_day ||= Array.new(days_total + 1) {0}.each_with_index.map do |day, i|
      @calendar.inject(0) do |sum, hacker|
        sum + hacker[i]
      end if i > 0
    end
  end

  def balance_amount
    @calendar.map do |row|
      j = 1
      amount = row[1..-1].inject(0) do |sum, presence|
        res = 0
        if not presence.zero?
          res = ((@house.amount / (nb_per_day[j] * days_total)) - amount_per_day)
        end
        j += 1
        sum + res
      end
      [row[0], amount.positive? ? amount.ceil : 0]
    end
  end
end