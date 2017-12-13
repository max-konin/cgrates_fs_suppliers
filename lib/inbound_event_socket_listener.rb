require 'fsr'
require 'fsr/listener/inbound'
require 'pp'
require_relative 'event_processors/channel_park_processor'

class InboundEventSocketListener < FSR::Listener::Inbound
  def before_session
    add_event(:CHANNEL_PARK) do |event|
      FSR::Log.info "*** Process CHANNEL_PARK event ***"
      res = EventProcessors::ChannelParkProcessor.new.process event
      FSR::Log.info "Response: #{res}"
      FSR::Log.info "*** End CHANNEL_PARK event ***"
    end
  end
end
