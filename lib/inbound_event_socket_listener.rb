require 'fsr'
require 'fsr/listener/inbound'
require 'pp'
require_relative 'event_processors/channel_park_processor'

class InboundEventSocketListener < FSR::Listener::Inbound
  def before_session
    add_event(:CHANNEL_PARK) do |event|
      FSR::Log.info "*** Process CHANNEL_PARK event ***"
      begin
        result =  EventProcessors::ChannelParkProcessor.new(FSR::Log).process event
        FSR::Log.info "Result: #{result}"
      rescue => e
        FSR::Log.fatal e.inspect
        FSR::Log.fatal e.backtrace.join('\n')
      end
      FSR::Log.info "*** End CHANNEL_PARK event ***"
      result
    end
  end
end
