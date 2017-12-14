require_relative '../cgrates_apier_adapter'
require 'logger'

module EventProcessors
  class ChannelParkProcessor
    attr_reader :logger

    def initialize(logger = Logger.new)
      @logger = logger
    end

    def process(event)
      if can_process? event
        logger.info 'Start processing CHANNEL_PARK event'
	params = build_cgrates_params(event)
        logger.info "Send request to CGRates with params #{params}"
        res = CgratesApierAdapter.new.execute method: 'SupplierSv1.GetSuppliers' , params: params
        logger.info "CGrates response: status #{res.status}, body = #{res.body}"
        res.body
      else 
        logger.info 'Can not process CHANNEL_PARK event'
        false
      end
    end

    private
    def can_process?(event)
        [:variable_cgr_account,
         :variable_cgr_subject].map { |n| !event.content[n].nil? && event.content[n] != '' }.reduce(:&)
    end

    def build_cgrates_params(event)
      [
        {
          'ID' => Config.instance.cgr_event_id,
          'Tenant' => event.content[:variable_cgr_tenant],
          'Event': {
            'Account'     => event.content[:variable_cgr_account],
            'Destination' => event.content[:caller_destination_number],
            'Subject'     => event.content[:variable_cgr_subject],
            'Category'    => 'call',
            'AnswerTime'  => event.content[:event_date_timestamp],
            'Usage': '1',
          },
        }
      ]
    end
  end
end
