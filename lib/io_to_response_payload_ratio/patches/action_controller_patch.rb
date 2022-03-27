require "action_controller"

module IoToResponsePayloadRatio
  module ActionControllerPatch
    class ::ActionController::Base
      def self.log_process_action(payload)
        custom_payload = payload[:io_to_response_payload_ratio]

        return super unless custom_payload

        messages, body_payload, input_payload = super, custom_payload[:body_payload], custom_payload[:input_payload]

        if IoToResponsePayloadRatio.logs?
          messages << "Input Payload: #{"%.2f" % (input_payload / 1000.0)}kB"
          messages << "Body: #{"%.2f" % (body_payload / 1000.0)}kB"
        else
          ActiveSupport::Notifications.instrument(
            "measurements.io_to_response_payload_ratio",
            body_payload: body_payload,
            input_payload: input_payload,
            controller_payload: payload
          )
        end

        IoToResponsePayloadRatio.check_treshold logger, input_payload, body_payload

        messages
      end

      private

      attr_internal :input_payload

      def process_action(action, *args)
        IoToResponsePayloadRatio::LogSubscriber.reset_input_payload
        super
      end
    end
  end
end