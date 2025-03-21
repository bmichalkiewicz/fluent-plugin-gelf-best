require "fluent/plugin/formatter"
require "fluent/plugin/gelf_plugin_util"
require 'oj'

module Fluent
  module TextFormatter
    class GelfFormatter < Formatter

      unless method_defined?(:log)
        define_method('log') { $log }
      end

      Plugin.register_formatter("gelf", self)

      include Fluent::GelfPluginUtil

      config_param :use_record_host, :bool, :default => true
      config_param :add_msec_time, :bool, :default => false
      config_param :max_bytes, :integer, :default => 32000

      def configure(conf)
        super(conf)
      end

      def format(tag, time, record)

        begin

          gelfentry = make_gelfentry(
            tag,time,record,
            {
              :use_record_host => @use_record_host,
              :add_msec_time => @add_msec_time,
              :max_bytes => @max_bytes
            }
          )

          Oj.dump(gelfentry)

        rescue Exception => e
          log.error sprintf(
            'Error trying to serialize %s: %s',
            record.to_s.force_encoding('UTF-8'),
            e.message.to_s.force_encoding('UTF-8')
          )
        end
      end
    end
  end
end
