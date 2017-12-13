require 'singleton'
require 'yaml'

class Config
  include Singleton

  CONFIG_FILE_PATH = File.expand_path("../../config.yml", __FILE__)

  attr_accessor :cgrates_url, :cgrates_user, :cgrates_token,:cgr_event_id,
                :freeswitch_host, :freeswitch_port, :freeswitch_auth

  def load
    config = YAML.load File.read(CONFIG_FILE_PATH)
    @cgrates_url = config['cgrates']['apier_url']
    @cgr_event_id = config['cgrates']['cgr_event_id']
    @cgrates_user = config['cgrates']['user']
    @cgrates_token = config['cgrates']['token']
    @freeswitch_host = config['freeswitch']['host']
    @freeswitch_port = config['freeswitch']['port']
    @freeswitch_auth = config['freeswitch']['auth']

    self
  end
end
