# coding: utf-8
require 'homebus'
require 'homebus_app'
require 'mqtt'
require 'dotenv'
require 'net/http'
require 'json'

class AQIHomeBusApp < HomeBusApp
  DDC = 'org.homebus.experimental.aqi'

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

    if aqi
      payload = aqi.map { |o| { name: o[:ParameterName], aqi: o[:AQI], condition: o[:Category][:Name], condition_index: o[:Category][:Number] }}

      answer =  {
        source: @uuid,
        timestamp: Time.now.to_i,
        contents: {
          ddc: DDC,
          payload: payload
        }
      }
 
      publish! DDC, answer

      if options[:verbose]
        puts answer
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
