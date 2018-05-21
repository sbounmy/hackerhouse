class HouseSynchronizer < ApplicationSynchronizer
  on :update do
    to :intercom do
      house = params[:house]
      App.intercom.companies.find(company_id: house.id.to_s).tap do |c|
        c.custom_attributes = {
          door_key: house.door_key,
          building_key: house.building_key
        }
        App.intercom.companies.save(c)
      end
    end
  end
end
