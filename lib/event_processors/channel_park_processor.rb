require_relative '../cgrates_apier_adapter'

module EventProcessors
  class ChannelParkProcessor
    def process(event)
      if can_process? event
        res = CgratesApierAdapter.new.execute method: 'SupplierSv1.GetSuppliers' , params: build_cgrates_params(event)
        res.body
      end
    end

    private
    def can_process?(event)
      event.content[:event_name] == :CHANNEL_PARK &&
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
