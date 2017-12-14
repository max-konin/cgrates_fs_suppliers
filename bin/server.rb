require_relative "../lib/inbound_event_socket_listener"

config = Config.instance.load
FSR.start_ies!(InboundEventSocketListener, host: config.freeswitch_host,
                                           port: config.freeswitch_port,
                                           auth: config.freeswitch_auth)
