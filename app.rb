# coding: utf-8
require 'homebus'
require 'homebus_app'
require 'mqtt'
require 'dotenv'
require 'net/http'
require 'json'

class AQIHomeBusApp < HomeBusApp
  def initialize(options)
    @options = options
    super
  end

  def update_delay
    15*60
  end

  def url
    # https://docs.airnowapi.org/CurrentObservationsByZip/query
    "http://www.airnowapi.org/aq/observation/zipCode/current/?format=application/json&zipCode=#{options[:zipcode]}&distance=25&API_KEY=#{ENV['AIRNOW_API_KEY']}"
  end

  def setup!
    Dotenv.load('.env')
  end

  def work!
    uri = URI(url)
    results = Net::HTTP.get(uri)

    aqi = JSON.parse results, symbolize_names: true
    pp aqi

    answer =         {
                    id: @uuid,
                    timestamp: Time.now.to_i,
                    observations: aqi.map { |o| { name: o[:ParameterName], aqi: o[:AQI], condition: o[:Category][:Name], condition_index: o[:Category][:Number] }}
    }
    pp answer
          
    @mqtt.publish '/aqi',
                  JSON.generate(answer),
                  true

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
    ''
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
