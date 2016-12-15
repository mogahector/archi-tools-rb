# frozen_string_literal: true
require 'test_helper'
require 'tempfile'

module Archimate
  module Cli
    class ArchiTest < Minitest::Test
      def setup
        @archi = Archi.new
        @test_file = Tempfile.new("test.archimate")
      end

      def teardown
        @test_file.close
        @test_file.unlink
      end

      # TODO: make this actually test something
      def test_map
        Archi.start(
          [
            "map",
            File.join(TEST_EXAMPLES_FOLDER, 'base.archimate'),
            "-o",
            @test_file,
            "-n"
          ]
        )
      end

      # TODO: make this actually test something
      def test_merge
        Archi.start(
          [
            "merge",
            File.join(TEST_EXAMPLES_FOLDER, 'base.archimate'),
            File.join(TEST_EXAMPLES_FOLDER, 'merger_1_1.archimate'),
            "-o",
            @test_file
          ]
        )
      end

      # TODO: make this actually test something
      def test_svg
        Dir.mktmpdir do |dir|
          Archi.start(["svg", "-o", dir, File.join(TEST_EXAMPLES_FOLDER, 'base.archimate'), "-n"])
        end
      end

      # TODO: make this actually test something
      def test_dupes
        Archi.start(%w(dupes --output /dev/null --force --noninteractive) << File.join(TEST_EXAMPLES_FOLDER, 'base.archimate'))
      end

      # TODO: make this actually test something
      def test_clean
        removed_items = Tempfile.new("test_clean_removed.xml")
        Archi.start(
          [
            "clean",
            File.join(TEST_EXAMPLES_FOLDER, 'base.archimate'),
            "-o",
            @test_file,
            "-r",
            removed_items,
            "--noninteractive"
          ]
        )
      ensure
        removed_items.close
        removed_items.unlink
      end

      # TODO: make this actually test something
      def test_dedupe
        Archi.start(
          [
            "dedupe",
            File.join(TEST_EXAMPLES_FOLDER, 'base.archimate'),
            "-o",
            @test_file,
            "-m",
            "-f",
            "-n"
          ]
        )
      end

      # TODO: make this actually test something
      def test_convert_meff
        Archi.start(
          [
            "convert",
            "-t",
            "meff2.1",
            File.join(TEST_EXAMPLES_FOLDER, 'base.archimate'),
            "-o",
            @test_file,
            "-f",
            "--noninteractive"
          ]
        )
      end

      # TODO: make this actually test something
      def test_convert_quads
        Archi.start(
          [
            "convert",
            "-t",
            "nquads",
            File.join(TEST_EXAMPLES_FOLDER, 'base.archimate'),
            "-o",
            @test_file,
            "-f",
            "--noninteractive"
          ]
        )
      end
    end
  end
end
