# frozen_string_literal: true

require 'test_helper'
require 'test_examples'
require "awesome_print"

module Archimate
  class DerivedRelationsTest < Minitest::Test
    DerivedRelationCase = Struct.new(:type, :source, :target)

    def setup
      @model = Archimate.read(
        File.join(
          TEST_EXAMPLES_FOLDER,
          "derived-relations-cases.archimate"
        )
      )
      @subject = DerivedRelations.new(@model)
      @a = @model.elements.find(&DataModel.by_name("A"))
      @b = @model.elements.find(&DataModel.by_name("B"))
      @d = @model.elements.find(&DataModel.by_name("D"))
      @d_api = @model.elements.find(&DataModel.by_name("D API"))
      @d_func = @model.elements.find(&DataModel.by_name("D Function"))
      @d_svc = @model.elements.find(&DataModel.by_name("D Service"))
      @app_func = @model.elements.find(&DataModel.by_name("Application Function"))

      @d_to_d_api = @model.relationships.find { |rel| rel.source == @d && rel.target == @d_api }
      @d_to_d_func = @model.relationships.find { |rel| rel.source == @d && rel.target == @d_func }
      @d_api_to_d_svc = @model.relationships.find { |rel| rel.source == @d_api && rel.target == @d_svc }
      @d_svc_to_app_func = @model.relationships.find { |rel| rel.source == @d_svc && rel.target == @app_func }
      @d_func_to_d_svc = @model.relationships.find { |rel| rel.source == @d_func && rel.target == @d_svc }
      @d_api_to_a = @model.relationships.find { |rel| rel.source == @d_api && rel.target == @a }
      @a_to_b = @model.relationships.find { |rel| rel.source == @a && rel.target == @b }
      @a_to_app_func = @model.relationships.find { |rel| rel.source == @a && rel.target == @app_func }
    end

    def test_element_by_name
      @model.elements.each do |el|
        assert_equal @model.elements.find(&DataModel.by_name(el.name)), el
      end
    end

    def test_traverse_for_simple_case_a
      app_comp_a = @model.elements.find(&DataModel.by_name("A"))
      expected = app_comp_a.source_relationships.map { |rel| [rel] }

      actual = @subject.traverse(
        [app_comp_a],
        ->(_rel) { true },
        ->(_el) { true }
      )

      assert_equal to_id_array(expected), to_id_array(actual)
    end

    def test_traverse_for_complex_case_d
      expected = [
        @d_to_d_api,
        @d_to_d_func,
        [@d_to_d_api, @d_api_to_d_svc],
        [@d_to_d_api, @d_api_to_a],
        [@d_to_d_api, @d_api_to_d_svc, @d_svc_to_app_func],
        [@d_to_d_api, @d_api_to_a, @a_to_b],
        [@d_to_d_api, @d_api_to_a, @a_to_app_func],
        [@d_to_d_func, @d_func_to_d_svc],
        [@d_to_d_func, @d_func_to_d_svc, @d_svc_to_app_func]
      ]

      actual = @subject.traverse(
        [@d],
        DerivedRelations::PASS_ALL,
        DerivedRelations::FAIL_ALL
      )

      assert_equal 9, actual.size
      expected.each { |path| assert_includes actual, path }
      assert_equal to_id_array(expected), to_id_array(actual)
    end

    def test_has_derived_relationships
      expected = [
        DerivedRelationCase.new('Assignment', @d.id, @d_svc.id),
        DerivedRelationCase.new('Serving', @d.id, @app_func.id),
        DerivedRelationCase.new('Realization', @d.id, @d_svc.id),
        DerivedRelationCase.new('Serving', @d.id, @a.id),
        DerivedRelationCase.new('Serving', @d.id, @b.id)
      ]

      actual = @subject.derived_relations(
        [@d],
        DerivedRelations::PASS_ALL,
        DerivedRelations::PASS_ALL,
        DerivedRelations::FAIL_ALL
      )

      assert_equal 5, actual.size
      actual.each do |rel|
        assert_kind_of DataModel::Relationship, rel
        assert rel.derived
        assert_includes expected, DerivedRelationCase.new(rel.type, rel.source.id, rel.target.id)
      end
    end

    def test_has_derived_serving_relationships_to_app_components
      expected = [
        DerivedRelationCase.new('Serving', @d.id, @a.id),
        DerivedRelationCase.new('Serving', @d.id, @b.id)
      ]

      actual = @subject.derived_relations(
        [@d],
        ->(rel) { rel.weight >= DataModel::Relationships::Serving::WEIGHT },
        ->(el) { el.type == "ApplicationComponent" }
      )

      assert_equal 2, actual.size
      actual.each do |rel|
        assert_kind_of DataModel::Relationship, rel
        assert rel.derived
        assert_includes expected, DerivedRelationCase.new(rel.type, rel.source.id, rel.target.id)
      end
    end

    private

    def to_id_array(items)
      items
        .map { |item| Array(item).map { |rel| "#{rel.source.name}->#{rel.target.name}" }.join(", ") }
    end

    def short_rel_desc(rel)
      "#{rel.source.type}: #{rel.source.name} -> #{rel.target.type}: #{rel.target.name}"
    end

    def to_textual_array(items)
      items
        .map do |item|
          rels = Array(item)
          <<~MESSAGE
            Derived Relation #{rels.first.source.type}: #{rels.first.source.name} -> #{rels.last.target.type}: #{rels.last.target.name}
                #{rels.map { |rel| short_rel_desc(rel) }.join("\n    ")}
          MESSAGE
        end
    end
  end
end
