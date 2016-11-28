# frozen_string_literal: true
require "nokogiri"
require "highline"
require "dry-types"
require "dry-struct"
require "archimate/version"
require 'archimate/data_model'
require 'archimate/aio'

HighLine.colorize_strings

module Archimate
  module Cli
    autoload :Archi, 'archimate/cli/archi'
    autoload :Cleanup, 'archimate/cli/cleanup'
    autoload :Convert, 'archimate/cli/convert'
    autoload :Diff, 'archimate/cli/diff'
    autoload :Duper, 'archimate/cli/duper'
    autoload :Mapper, 'archimate/cli/mapper'
    autoload :Merge, 'archimate/cli/merge'
    autoload :Merger, 'archimate/cli/merger'
    autoload :Svger, 'archimate/cli/svger'
  end

  module Export
    autoload :NQuads, 'archimate/export/n_quads'
    autoload :GraphML, 'archimate/export/graph_ml'
  end

  module Diff
    autoload :Change, 'archimate/diff/change'
    autoload :Conflict, 'archimate/diff/conflict'
    autoload :Conflicts, 'archimate/diff/conflicts'
    autoload :Context, 'archimate/diff/context'
    autoload :Delete, 'archimate/diff/delete'
    autoload :Difference, 'archimate/diff/difference'
    autoload :Insert, 'archimate/diff/insert'
    autoload :Merge, 'archimate/diff/merge'
    class Conflicts
      autoload :BaseConflict, 'archimate/diff/conflicts/base_conflict'
      autoload :DeletedElementsReferencedInDiagramsConflict, 'archimate/diff/conflicts/deleted_elements_referenced_in_diagrams_conflict'
      autoload :DeletedElementsReferencedInRelationshipsConflict, 'archimate/diff/conflicts/deleted_elements_referenced_in_relationships_conflict'
      autoload :DeletedRelationshipsReferencedInDiagramsConflict, 'archimate/diff/conflicts/deleted_relationships_referenced_in_diagrams_conflict'
      autoload :DiagramDeleteUpdateConflict, 'archimate/diff/conflicts/diagram_delete_update_conflict'
      autoload :PathConflict, 'archimate/diff/conflicts/path_conflict'
    end
  end

  module FileFormats
    autoload :ArchiFileFormat, 'archimate/file_formats/archi_file_format'
    autoload :ArchiFileReader, 'archimate/file_formats/archi_file_reader'
    autoload :ArchiFileWriter, 'archimate/file_formats/archi_file_writer'
    autoload :ModelExchangeFileFormat, 'archimate/file_formats/model_exchange_file_format'
    autoload :ModelExchangeFileReader, 'archimate/file_formats/model_exchange_file_reader'
    autoload :ModelExchangeFileWriter, 'archimate/file_formats/model_exchange_file_writer'
    autoload :Writer, 'archimate/file_formats/writer'
  end

  autoload :FileFormat, 'archimate/file_format'
  autoload :MaybeIO, 'archimate/maybe_io'
  autoload :OutputIO, 'archimate/output_io'

  # Creates a new generic xml document given an optional string source
  #
  # @param xml_str Optional string of xml to parse as initial document
  def self.new_xml_doc(xml_str = nil)
    Nokogiri::XML::Document.new(xml_str)
  end

  def self.diff(local, remote)
    Diff::Context.new(local, remote, local, remote).diffs
  end

  # Reads the given file and returns the Archimate model
  #
  # @param filename File name of the file to read
  # @return Archimate::DataModel::Model of ArchiMate model in the file
  def self.read(filename)
    FileFormat.read(filename)
  end

  # Reads the given file and returns the Archimate model
  #
  # @param filename File name of the file to read
  # @return Archimate::DataModel::Model of ArchiMate model in the file
  def self.parse(filename)
    FileFormat.parse(filename)
  end
end
