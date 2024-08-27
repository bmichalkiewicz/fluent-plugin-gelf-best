module Fluent
  module GelfPluginUtil
    require "gelf"
    require "date"

    LEVEL_MAP = {
      "0" => GELF::UNKNOWN, "1" => GELF::UNKNOWN, "a" => GELF::UNKNOWN,
      "2" => GELF::FATAL, "c" => GELF::FATAL,
      "3" => GELF::ERROR,
      "4" => GELF::WARN, "w" => GELF::WARN,
      "5" => GELF::INFO, "n" => GELF::INFO,
      "6" => GELF::INFO, "i" => GELF::INFO,
      "7" => GELF::DEBUG, "d" => GELF::DEBUG,
      "e" => GELF::ERROR  # assuming 'e' stands typically for 'error'
    }.freeze

    def make_gelfentry(tag, time, record, conf = {})
      gelfentry = {'_fluentd_tag' => tag, 'timestamp' => calculate_timestamp(time)}

      record.each_pair do |k, v|
        gelfentry.merge!(process_record_entry(k, v, conf, gelfentry))
      end

      ensure_short_message(gelfentry)
      gelfentry.compact
    end

    private

    def calculate_timestamp(time)
      if defined?(Fluent::EventTime) && time.is_a?(Fluent::EventTime)
        time.sec + (time.nsec.to_f / 1_000_000_000).round(3)
      else
        time
      end
    end

    def process_record_entry(k, v, conf, gelfentry)
      # Truncate values longer than max_bytes
      v = (v.respond_to?(:bytesize) && v.bytesize > conf[:max_bytes]) ? "#{v.byteslice(0, conf[:max_bytes] - 3)}..." : v

      case k
      when 'host', 'hostname'
        return {'host' => (conf[:use_record_host] ? v : gelfentry['_host'] = v)}
      when 'timestamp', 'time'
        { 'timestamp' => parse_timestamp(v) }
      when 'level'
        {'level' => LEVEL_MAP[v.to_s.downcase[0]] || (v.to_s.length >= 2 && v.to_s.downcase[1] != "r" ? GELF::UNKNOWN : v)}
      when 'msec'
        conf[:add_msec_time] ? {'timestamp' => "#{time.to_s}.#{v}".to_f} : {'_msec' => v}
      when 'short_message', 'version', 'full_message', 'facility', 'file', 'line'
        {k => v}
      else
        {k.start_with?('_') ? k : "_#{k}" => v}
      end
    end

    def parse_timestamp(v)
      if v.is_a?(Integer) || v.is_a?(Float)
        v
      else
        begin
          (DateTime.parse(v).strftime("%Q").to_f / 1_000).round(3)
        rescue ArgumentError
          v
        end
      end
    end

    def ensure_short_message(gelfentry)
      return if gelfentry['short_message'] && !gelfentry['short_message'].to_s.strip.empty?

      ['_message', '_msg', '_log', '_record'].each do |key|
        if gelfentry[key] && !gelfentry[key].to_s.strip.empty?
          gelfentry['short_message'] = gelfentry.delete(key)
          return
        end
      end

      gelfentry['short_message'] = '(no message)' unless gelfentry['short_message']
    end
  end
end
