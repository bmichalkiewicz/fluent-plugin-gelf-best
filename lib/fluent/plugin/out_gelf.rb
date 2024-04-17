require "fluent/plugin/output"
require "fluent/plugin/gelf_plugin_util"

module Fluent
  module Plugin
    class GelfOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output('gelf', self)

      include Fluent::GelfPluginUtil

      config_param :use_record_host, :bool, :default => false
      config_param :add_msec_time, :bool, :default => false
      config_param :host, :string, :default => nil
      config_param :port, :integer, :default => 12201
      config_param :protocol, :string, :default => 'udp'
      config_param :tls, :bool, :default => false
      config_param :tls_options, :hash, :default => {}

      define_method('log') {$log} unless method_defined?(:log)

      DEFAULT_BUFFER_TYPE = 'memory'.freeze
      DEFAULT_TIMEKEY = 5
      DEFAULT_TIMEKEY_WAIT = 0
      MAX_PAYLOAD_SIZE = 1000000 # bytes

      config_section :buffer do
        config_set_default :@type, DEFAULT_BUFFER_TYPE
        config_set_default :chunk_keys, ['time']
        config_set_default :timekey, DEFAULT_TIMEKEY
        config_set_default :timekey_wait, DEFAULT_TIMEKEY_WAIT
      end

      def multi_workers_ready?
        true
      end

      def formatted_to_msgpack_binary
        true
      end

      def configure(conf)
        super(conf)

        # a destination hostname or IP address must be provided
        raise Fluent::ConfigError.new("'host' parameter (hostname or address of Graylog2 server) is required") unless conf.has_key?('host')

        # choose protocol to pass to gelf-rb Notifier constructor
        # (@protocol is used instead of conf['protocol'] to leverage config_param default)
        if @protocol == 'udp' then @proto = GELF::Protocol::UDP
        elsif @protocol == 'tcp' then @proto = GELF::Protocol::TCP
        else raise Fluent::ConfigError.new("'protocol' parameter should be either 'udp' (default) or 'tcp'")
        end
      end

      def start
        super

        options = {:facility => 'fluentd', :protocol => @proto}

        # add tls key (tls_options) only when tls = True
        # see https://github.com/graylog-labs/gelf-rb/blob/72916932b789f7a6768c3cdd6ab69a3c942dbcef/lib/gelf/notifier.rb#L133-L140
        if @tls then
          options[:tls] = @tls_options
        end

        @conn = GELF::Notifier.new(@host, @port, 'WAN', options)

        # Errors are not coming from Ruby so we use direct mapping
        @conn.level_mapping = 'direct'
        # file and line from Ruby are in this class, not relevant
        @conn.collect_file_and_line = false
      end

      def shutdown
        super
      end

      def format(tag, time, record)
        if defined? Fluent::EventTime and time.is_a? Fluent::EventTime then
          timestamp = time.to_i + (time.nsec.to_f/1000000000).round(3)
        else
          timestamp = time.to_i
        end

        begin
          make_gelfentry(
            tag,timestamp,record,
            {
              :use_record_host => @use_record_host,
              :add_msec_time => @add_msec_time
            }
          ).to_msgpack
        rescue Exception => e
          log.error sprintf(
            'Error trying to serialize %s: %s',
            record.to_s.force_encoding('UTF-8'),
            e.message.to_s.force_encoding('UTF-8')
          )
        end
      end

      def write(chunk)
        chunk.msgpack_each do |data|
          begin
            @conn.notify!(data)
          rescue Exception => e
            log.warn "failed to flush the buffer.", error_class: e.class.to_s, error: e.to_s, plugin_id: plugin_id
            raise e
          end
        end
      end
    end
  end
end
