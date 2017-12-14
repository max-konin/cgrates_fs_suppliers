require_relative '../cgrates_apier_adapter'
require 'logger'

module EventProcessors
  class ChannelParkProcessor
    attr_reader :logger

    def initialize(logger = Logger.new(STDOUT))
      @logger = logger
    end

    def process(event)
      if can_process? event
        logger.info 'Start processing CHANNEL_PARK event'
        params = build_cgrates_params(event)
        logger.info "Send request to CGRates with params #{params}"
        res = CgratesApierAdapter.new.execute method: 'SupplierSv1.GetSuppliers' , params: params
        logger.info "CGrates response: status #{res.status}, body = #{res.body}"
        process_cgaretes_response event, res
      else
        logger.info 'Can not process CHANNEL_PARK event'
        false
      end
    end

    private
    def process_cgaretes_response(event, res)
      suppls = res.body['result'].first['SortedSuppliers'].map { |s| s['SupplierID'] }
      channel_call_uuid = event.content[:channel_call_uuid]
      "uuid_setvar #{channel_call_uuid} cgr_suppliers ARRAY::#{suppls.size}|:#{suppls.join '|:'}"
    rescue => e
      logger.error e.inspect
    end

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
