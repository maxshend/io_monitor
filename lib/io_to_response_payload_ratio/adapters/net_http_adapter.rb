# frozen_string_literal: true

require "net/http"
require "io_to_response_payload_ratio/patches/net_http_adapter_patch"

module IoToResponsePayloadRatio
  class NetHttpAdapter < BaseAdapter
    def self.kind
      :net_http
    end

    def initialize!
      ActiveSupport.on_load(:after_initialize) do
        Net::HTTP.prepend(NetHttpAdapterPatch)

        if defined?(::WebMock)
          WebMock::HttpLibAdapters::NetHttpAdapter
            .instance_variable_get(:@webMockNetHTTP)
            .prepend(NetHttpAdapterPatch)
        end
      end
    end
  end
end
