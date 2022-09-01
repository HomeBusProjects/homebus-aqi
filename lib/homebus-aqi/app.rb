# coding: utf-8

require 'homebus'

require 'dotenv'

require 'net/http'
require 'json'

class HomebusAqi::App < Homebus::App
  DDC_PM = 'org.homebus.experimental.aqi-pm25'
  DDC_O3 = 'org.homebus.experimental.aqi-o3'

  def initialize(options)
    @options = options
    super
  end

  def update_interval
    15*60
  end

  def setup!
    Dotenv.load('.env')
    @airnow_api_key = ENV['AIRNOW_API_KEY']
    @zipcode = @options[:zipcode] || ENV['ZIPCODE']

    @device = Homebus::Device.new name: "Air Quality Index for #{@zip_code}",
                                  manufacturer: 'Homebus',
                                  model: 'AQI publisher',
                                  serial_number: @zip_code

  end

  def _url
    # https://docs.airnowapi.org/CurrentObservationsByZip/query
    "http://www.airnowapi.org/aq/observation/zipCode/current/?format=application/json&zipCode=#{@zipcode}&distance=25&API_KEY=#{@airnow_api_key}"
  end

  def _get_aqi
    begin
      uri = URI(_url)
      results = Net::HTTP.get(uri)

      aqi = JSON.parse results, symbolize_names: true
      return aqi
    rescue
      nil
    end
  end

  def work!
    aqi = _get_aqi

    if options[:verbose]
      pp aqi
    end

    if aqi
      aqi_pm25 = aqi.select { |a| a[:ParameterName] == 'PM2.5' }
      aqi_o3   = aqi.select { |a| a[:ParameterName] == 'O3' }

      if aqi_pm25.length > 0
        payload = {
          aqi: aqi_pm25[0][:AQI],
          condition: aqi_pm25[0][:Category][:Name],
          condition_index: aqi_pm25[0][:Category][:Number]
        }

        publish! DDC_PM, payload

        if options[:verbose]
          pp DDC_PM, payload
        end
      end

      if aqi_o3.length > 0
        payload = {
          aqi: aqi_o3[0][:AQI],
          condition: aqi_o3[0][:Category][:Name],
          condition_index: aqi_o3[0][:Category][:Number]
        }

        publish! DDC_O3, payload

        if options[:verbose]
          pp DDC_O3, payload
        end
      end
    end

    sleep update_interval
  end

  def name
    'Homebus AQI publisher'
  end

  def publishes
    [ DDC_PM, DDC_O3 ]
  end

  def devices
    [ @device ]
  end
end
