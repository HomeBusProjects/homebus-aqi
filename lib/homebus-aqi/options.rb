require 'homebus/options'
require 'homebus-aqi/version'

class HomebusAqi::Options < Homebus::Options
  def app_options(op)
    zipcode_help = 'the zip code of the reporting area'

    op.separator 'AQI options:'
    op.on('-z', '--zip-code ZIPCODE', zipcode_help) { |value| options[:zipcode] = value }
  end

  def banner
    'HomeBus Air Quality Index publisher'
  end

  def version
    HomebusAqi::VERSION
  end

  def name
    'homebus-aqi'
  end
end
