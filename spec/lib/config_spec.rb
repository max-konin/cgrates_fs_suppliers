require  File.expand_path("lib/config")
describe Config do
  describe '#load' do
    let(:config) { Config.instance }

    it 'loads configs from config.yml' do
      config.load
      expect(config.cgrates_url).to eq 'http://cgrates.example.com'
      expect(config.freeswitch_host).to eq 'localhost'
      expect(config.freeswitch_port).to eq 8021
      expect(config.freeswitch_auth).to eq 'ClueCon'
    end
  end
end
