# frozen_string_literal: true

module TimecopHelper
  extend RSpec::SharedContext

  around do |example|
    Timecop.freeze(example.metadata[:freeze_at]) do
      example.run
    end
  end
end
