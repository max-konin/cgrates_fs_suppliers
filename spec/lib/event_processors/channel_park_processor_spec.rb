require File.expand_path("lib/event_processors/channel_park_processor")

describe EventProcessors::ChannelParkProcessor do
  describe '#process' do
    let(:cgrates_endpoint) { 'http://cgrates.example.com/jsonrpc' }
    let(:config) { Config.instance }
    let(:event_struct) { Struct.new :content }

    subject { EventProcessors::ChannelParkProcessor.new.process event }

    before do
      stub_request(:post, cgrates_endpoint).and_return(body: {
          result: [
            'ProfileID' => 1,
            'Sorting' => :asc,
            'SortedSuppliers' => [:hansa, :telux]
          ]
      }.to_json)
      config.load()
    end

    context 'when event name is "CHANNEL_PARK"' do
      let(:event_name) { :CHANNEL_PARK }
      let(:expected_response) do
        {
          'result' => [
            'ProfileID' => 1,
            'Sorting' => 'asc',
            'SortedSuppliers' => ['hansa', 'telux']
          ]
        }
      end

      context 'when event has "cgr_account" & "cgr_subject"' do
        let(:event) do
          event_struct.new({
              event_name: event_name,
              'Event-Date-Timestamp': '2017',
              'Caller-Destination-Number': '123',
              cgr_account: '1001',
              cgr_subject: 'EU',
              cgr_tenant: 'cgrates.org',
              cgr_reqtype: '*prepaid'
          })
        end

        it 'sends correct request to CGrates' do
          subject
          expected_request_body = {
            method: 'SupplierSv1.GetSuppliers',
            params: [
              {
                'ID' => config.cgr_event_id,
                'Tenant' => 'cgrates.org',
                'Event': {
                  'Account'     => '1001',
                  'Destination' => '123',
                  'Subject'     => 'EU',
                  'Category'    => 'call',
                  'AnswerTime'  => '2017',
                  'Usage': '1',
                },
              }
            ]
          }
          expect(WebMock).to have_requested(:post, cgrates_endpoint).with(body: expected_request_body)
        end

        it { expect(subject).to eq  expected_response }
      end

      context 'when event has not "cgr_account" & "cgr_subject"' do
        let(:event) do
          event_struct.new({
              event_name: event_name
          })
        end

        before { subject }
        it { expect(WebMock).not_to have_requested(:post, cgrates_endpoint) }
      end
    end

    context 'when event name is not "CHANNEL_PARK"' do
      let(:event_name) { :FAKE }

      let(:event) do
        event_struct.new({
            event_name: event_name
        })
      end

      before { subject }
      it { expect(WebMock).not_to have_requested(:post, cgrates_endpoint) }
    end
  end
end
