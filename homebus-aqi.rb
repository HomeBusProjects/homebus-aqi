#!/usr/bin/env ruby

require './options'
require './app'

aqi_app_options = AQIHomeBusAppOptions.new

aqi = AQIHomeBusApp.new aqi_app_options.options
aqi.run!
