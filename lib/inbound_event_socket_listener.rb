require 'fsr'
require 'fsr/listener/inbound'
require 'pp'
require_relative 'event_processors/channel_park_processor'

class InboundEventSocketListener < FSR::Listener::Inbound
  def on_event(event)
    pp event.content
    pp event.headers
    EventProcessors::ChannelParkProcessor.new.process event
  end
end
