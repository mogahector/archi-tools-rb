# frozen_string_literal: true

require 'test_helper'

module Archimate
  module Svg
    module Entity
      class InfrastructureServiceTest < Minitest::Test
        def setup
          @model = build_model(
            diagrams: [
              build_diagram
            ]
          )
          @child = @model.diagrams.first.nodes.first
          @subject = InfrastructureService.new(@child, build_bounds)
        end

        def test_badge
          assert_equal "#archimate-service-badge", @subject.instance_variable_get(:@badge)
        end
      end
    end
  end
end
