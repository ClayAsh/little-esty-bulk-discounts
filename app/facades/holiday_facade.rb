class HolidayFacade
  def self.create_holidays
    json = HolidayService.holiday_info 
    json.first(3).map do |info|
      Holiday.new(info)
    end 
  end
end