# Fluentd GELF output and formatter plugins
This is a fork of the fluent-plugin-gelf-hs (https://github.com/hotschedules/fluent-plugin-gelf-hs), which is no longer maintained.

## Overview
A Fluentd output plugin that sends logs to Graylog2.

## Prerequisites
Fluentd version 1.0 or higher.

## Installation

Add the plugin to your fluentd agent:

`fluent-gem install fluent-plugin-gelf-best`

If you are using td-agent:

`td-agent-gem install fluent-plugin-gelf-best`

For more info, review [Fluentd's official documentation](https://docs.fluentd.org/deployment/plugin-management).


## Output plugin configuration
```
<match **>
  type gelf
  host <remote GELF host>
  port <remote GELF port>
  protocol <tcp or udp (default)>
  udp_transport_type <LAN or WAN(default)>
  max_bytes <maximum message size (3200 default)>
  tls <true or false (default)>
  tls_options <{} (default)> for options see https://github.com/graylog-labs/gelf-rb/blob/72916932b789f7a6768c3cdd6ab69a3c942dbcef/lib/gelf/transport/tcp_tls.rb#L7-L12
  [ fluent buffered output plugin configuration ]
</match>
```

## Formatter plugin configuration
```
<match **>
  type file (any type that that takes a format argument)
  format gelf
  [ fluent file output plugin configuration ]
</match>
```

## License

fluent-plugin-gelf-best is licensed under the [Apache 2.0](http://apache.org/licenses/LICENSE-2.0.txt) License.

## Copyright

* Copyright(c) 2024 - Bartosz Michałkiewicz
* License
  * Apache License, Version 2.0
