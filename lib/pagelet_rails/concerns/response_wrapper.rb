module PageletRails::Concerns::ResponseWrapper
  extend ActiveSupport::Concern

  def process_action *args
    super.tap do
      if params[:target_container] &&
        action_has_layout? &&
        request.format.js? # wrap to js only if requested js

        response.content_type = 'text/javascript'

        html = self.response_body.reduce('') { |memo, body|
          memo << body
          memo
        }

        if html.match /^\s*</
          # the body could be javascript, make sure it's html before wrapping

          id = ActionController::Base.helpers.escape_javascript params[:target_container]
          js = ActionController::Base.helpers.escape_javascript html

          html = ActionController::Base.helpers.raw(
            "PageletRails.pageletArrived('#{id}', '#{js}');"
          )

          self.response_body = [html]
        end
      end
    end
  end

end
