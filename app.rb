# coding: utf-8

require 'homebus'
require 'homebus_app'

require 'dotenv'

require 'net/http'
require 'json'

class AQIHomeBusApp < HomeBusApp
  DDC_PM = 'org.homebus.experimental.aqi-pm25'
  DDC_O3 = 'org.homebus.experimental.aqi-o3'

  def initialize(options)
    @options = options
    super
  end

  def update_delay
    15*60
  end

  def setup!
    Dotenv.load('.env')
    @airnow_api_key = ENV['AIRNOW_API_KEY']
    @zipcode = @options[:zipcode] || ENV['ZIPCODE']
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

      if aqi_pm25
        payload = {
          aqi: aqi_pm25[:AQI],
          condition: aqi_pm25[:Category][:Name],
          condition_index: aqi_pm25[:Category][:Number]
        }

        publish! DDC_PM, payload

        if options[:verbose]
          pp DDC_PM25, payload
        end
      end

      if aqi_o3
        payload = {
          aqi: aqi_o3[:AQI],
          condition: aqi_o3[:Category][:Name],
          condition_index: aqi_o3[:Category][:Number]
        }

        publish! DDC_O3, payload

        if options[:verbose]
          pp DDC_O3, payload
        end
      end


      if options[:verbose]
        pp payload
      end
    end

    sleep update_delay
  end

  def manufacturer
    'HomeBus'
  end

  def model
    'Air Quality Index'
  end

  def friendly_name
    'Air Quality Index'
  end

  def friendly_location
    'Portland, OR'
  end

  def serial_number
    @zipcode
  end

  def pin
    ''
  end

  def devices
    [
      { friendly_name: 'Air Quality Index',
        friendly_location: 'Portland, OR',
        update_frequency: update_delay,
        index: 0,
        accuracy: 0,
        precision: 0,
        wo_topics: [ '/aqi' ],
        ro_topics: [],
        rw_topics: []
      }
    ]
  end
end
