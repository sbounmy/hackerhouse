class UserSynchronizer < ApplicationSynchronizer
  def update_intercom
    user = params[:user]
    App.intercom.users.find(user_id: user.id).tap do |u|
      u.custom_attributes = {
        check_out: user.check_out,
        phone_number: user.phone_number
      }
      App.intercom.users.save(u)
    end
  end

  def update_stripe
    user = params[:user]
    App.stripe do
      Stripe::Customer.retrieve(user.stripe_id).tap do |c|
        c.email = user.email
        c.metadata[:oid] = user.id.to_s
        # this will break if someone move to another hackerhouse
        Stripe::Subscription.list(customer: user.stripe_id).each do |s|
          s.metadata[:house] = user.house.slug_id
          s.metadata[:check_in] = user.check_in
          s.metadata[:check_out] = user.check_out
          s.save
        end
        c.save
      end
    end if user.stripe_id
  end

  # https://www.levups.com/en/blog/2017/undocumented-dirty-attributes-activerecord-changes-rails51.html
  def update_mailer
    user = params[:user]
    _check_out_was = user.previous_changes[:check_out] && user.previous_changes[:check_out][0]

    if !user.admin && user.previous_changes[:check_out] && user.check_out.future?
      if (_check_out_was > user.check_out)
        UserMailer.with(user: user).check_out_earlier_email.deliver_now
      elsif (_check_out_was < user.check_out)
        UserMailer.with(user: user).check_out_later_email.deliver_now
      end
    end
  end

end