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
        process_cgaretes_response res
      else
        logger.info 'Can not process CHANNEL_PARK event'
        false
      end
    end

    private
    def process_cgaretes_response(res)
      return nil if incorrect_response?(res)
      res.body['result'].first['SortedSuppliers'].map { |s| "cgr_supplier=#{s['SupplierID']}"}
    end

    def incorrect_response?(res)
      result = res.body['result']
      !(res.body['result'].is_a?(Array) && res.body['result'].first.is_a?(Hash) &&
          res.body['result'].first['SortedSuppliers'].is_a?(Array))
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
