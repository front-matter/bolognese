module Bolognese
  module Writers
    module CsvWriter
      require "csv"

      def csv
        bib = {
          doi: doi,
          url: url,
          registered: get_iso8601_date(date_registered),
          state: state,
          resource_type_general: types.respond_to?(:to_h) ? types.to_h["resourceTypeGeneral"] : nil,
          resource_type: types.respond_to?(:to_h) ? types.to_h["resourceType"] : nil,
          title: parse_attributes(titles, content: "title", first: true),
          author: authors_as_string(creators),
          publisher: publisher.respond_to?(:to_h) ? publisher.to_h["name"] : nil,
          publication_year: publication_year
        }.values

        CSV.generate { |csv| csv << bib }
      end
    end
  end
end
