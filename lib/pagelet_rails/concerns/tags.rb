module PageletRails::Concerns::Tags
  extend ActiveSupport::Concern

  included do
    helper_method :identified_by
    helper_method :trigger_change
  end

  def trigger_change tag = nil
    @trigger_change ||= []
    if tag.present?
      @trigger_change << tag
    end
    @trigger_change
  end

  def identified_by tag = nil
    @identified_by ||= []
    if tag.present?
      @identified_by << tag
    end
    @identified_by
  end
end
