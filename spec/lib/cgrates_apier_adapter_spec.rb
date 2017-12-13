require File.expand_path("lib/cgrates_apier_adapter")


describe CgratesApierAdapter do
  describe '#execute' do
    let(:cgrates_endpoint) { 'http://cgrates.example.com/jsonrpc' }
    let(:method) { 'SupplierSv1.GetSuppliers' }
    let(:params) { [{'Tenant': 'cgrates'}] }
    let(:expected_body) { { method: method, params: params }}

    before { Config.instance.load() }

    subject do
      CgratesApierAdapter.new.execute method: method, params: params
    end

    context 'when cgrates returns OK' do
      before do
        stub_request(:post, cgrates_endpoint).to_return(body: {result: :ok}.to_json, status: 200)
      end

      it { subject; expect(WebMock).to have_requested(:post, cgrates_endpoint).with(body: expected_body) }
      it { expect(subject.body).to eq('result' => 'ok') }
    end

    context 'when cgrates returns error' do
      before do
        stub_request(:post, cgrates_endpoint).to_return(body: { error: :not_ok }.to_json, status: 422)
      end

      it { subject; expect(WebMock).to have_requested(:post, cgrates_endpoint).with(body: expected_body) }
      it { expect{subject}.not_to raise_error }
      it { expect(subject.body).to eq('error' => 'not_ok') }
    end
  end
end
