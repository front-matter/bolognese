# frozen_string_literal: true

require_relative 'doi_utils'
require_relative 'author_utils'
require_relative 'datacite_utils'
require_relative 'utils'

require_relative 'readers/bibtex_reader'
require_relative 'readers/citeproc_reader'
require_relative 'readers/codemeta_reader'
require_relative 'readers/crosscite_reader'
require_relative 'readers/crossref_reader'
require_relative 'readers/datacite_json_reader'
require_relative 'readers/datacite_reader'
require_relative 'readers/ris_reader'
require_relative 'readers/schema_org_reader'

require_relative 'writers/bibtex_writer'
require_relative 'writers/citation_writer'
require_relative 'writers/citeproc_writer'
require_relative 'writers/codemeta_writer'
require_relative 'writers/crosscite_writer'
require_relative 'writers/crossref_writer'
require_relative 'writers/datacite_writer'
require_relative 'writers/datacite_json_writer'
require_relative 'writers/jats_writer'
require_relative 'writers/rdf_xml_writer'
require_relative 'writers/ris_writer'
require_relative 'writers/schema_org_writer'
require_relative 'writers/turtle_writer'

module Bolognese
  module MetadataUtils
    # include BenchmarkMethods
    include Bolognese::DoiUtils
    include Bolognese::AuthorUtils
    include Bolognese::DataciteUtils
    include Bolognese::Utils

    include Bolognese::Readers::BibtexReader
    include Bolognese::Readers::CiteprocReader
    include Bolognese::Readers::CodemetaReader
    include Bolognese::Readers::CrossciteReader
    include Bolognese::Readers::CrossrefReader
    include Bolognese::Readers::DataciteReader
    include Bolognese::Readers::DataciteJsonReader
    include Bolognese::Readers::RisReader
    include Bolognese::Readers::SchemaOrgReader

    include Bolognese::Writers::BibtexWriter
    include Bolognese::Writers::CitationWriter
    include Bolognese::Writers::CiteprocWriter
    include Bolognese::Writers::CodemetaWriter
    include Bolognese::Writers::CrossciteWriter
    include Bolognese::Writers::CrossrefWriter
    include Bolognese::Writers::DataciteWriter
    include Bolognese::Writers::DataciteJsonWriter
    include Bolognese::Writers::JatsWriter
    include Bolognese::Writers::RdfXmlWriter
    include Bolognese::Writers::RisWriter
    include Bolognese::Writers::SchemaOrgWriter
    include Bolognese::Writers::TurtleWriter

    attr_accessor :string, :from, :sandbox, :meta, :regenerate, :issue, :contributor
    attr_reader :doc, :service_provider, :page_start, :page_end, :reverse, :name_detector

    # replace DOI in XML if provided in options
    def raw
      r = string.present? ? string.strip : nil
      return r unless (from == "datacite" && r.present?)

      doc = Nokogiri::XML(string, nil, 'UTF-8', &:noblanks)
      node = doc.at_css("identifier")
      node.content = doi.to_s.upcase if node.present? && doi.present?
      doc.to_xml.strip
    end

    def should_passthru
      (from == "datacite") && regenerate.blank? && raw.present?
    end

    def editor
      @editor ||= meta.fetch("editor", nil)
    end

    def service_provider
      @service_provider ||= meta.fetch("service_provider", nil)
    end

    def volume
      @volume ||= meta.fetch("volume", nil)
    end

    def first_page
      @first_page ||= meta.fetch("first_page", nil)
    end

    def last_page
      @last_page ||= meta.fetch("last_page", nil)
    end

    # recognize given name. Can be loaded once as ::NameDetector, e.g. in a Rails initializer
    def name_detector
      @name_detector ||= defined?(::NameDetector) ? ::NameDetector : nil
    end

    def reverse
      { "citation" => Array.wrap(related_identifiers).select { |ri| ri["relation_type"] == "IsReferencedBy" }.map do |r| 
        { "@id" => normalize_doi(r["id"]),
          "@type" => r["resource_type_general"] || "CreativeWork",
          "identifier" => r["related_identifier_type"] == "DOI" ? nil : to_identifier(r) }.compact
        end.unwrap,
        "isBasedOn" => Array.wrap(related_identifiers).select { |ri| ri["relation_type"] == "IsSupplementTo" }.map do |r| 
          { "@id" => normalize_doi(r["id"]),
            "@type" => r["resource_type_general"] || "CreativeWork",
            "identifier" => r["related_identifier_type"] == "DOI" ? nil : to_identifier(r) }.compact
        end.unwrap }.compact
    end

    def graph
      RDF::Graph.new << JSON::LD::API.toRdf(schema_hsh)
    end

    def citeproc_hsh
      {
        "type" => citeproc_type,
        "id" => identifier,
        "categories" => Array.wrap(keywords).map { |k| parse_attributes(k, content: "text", first: true) }.presence,
        "language" => language,
        "author" => to_citeproc(creator),
        "editor" => to_citeproc(editor),
        "issued" => get_date(dates, "Issued") ? get_date_parts(get_date(dates, "Issued")) : nil,
        "submitted" => Array.wrap(dates).find { |d| d["type"] == "Submitted" }.to_h.fetch("__content__", nil),
        "abstract" => parse_attributes(description, content: "text", first: true),
        "container-title" => periodical && periodical["title"],
        "DOI" => doi,
        "issue" => issue,
        "page" => [first_page, last_page].compact.join("-").presence,
        "publisher" => publisher,
        "title" => parse_attributes(title, content: "text", first: true),
        "URL" => url,
        "version" => version,
        "volume" => volume
      }.compact.symbolize_keys
    end

    def style
      @style ||= "apa"
    end

    def locale
      @locale ||= "en-US"
    end
  end
end
