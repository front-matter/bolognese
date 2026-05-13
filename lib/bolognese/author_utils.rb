# frozen_string_literal: true

require 'namae'

module Bolognese
  module AuthorUtils

    IDENTIFIER_SCHEME_URIS = {
      "ORCID" => "https://orcid.org/"
    }

    def get_one_author(author)
      # author is a string
      author = { "creatorName" => author } if author.is_a?(String)

      # malformed XML
      return nil if author.fetch("creatorName", nil).is_a?(Array)

      name = parse_attributes(author.fetch("creatorName", nil)) ||
             parse_attributes(author.fetch("contributorName", nil))
      given_name = parse_attributes(author.fetch("givenName", nil))
      family_name = parse_attributes(author.fetch("familyName", nil))
      name = cleanup_author(name)
      contributor_type = parse_attributes(author.fetch("contributorType", nil))

      name_type = parse_attributes(author.fetch("creatorName", nil), content: "nameType", first: true) || parse_attributes(author.fetch("contributorName", nil), content: "nameType", first: true)

      name_identifiers = Array.wrap(author.fetch("nameIdentifier", nil)).map do |ni|
        name_identifier = ni["__content__"].strip if ni["__content__"].present?
        if ni["nameIdentifierScheme"] == "ORCID"
          {
            "nameIdentifier" => normalize_orcid(name_identifier),
            "schemeUri" => "https://orcid.org",
            "nameIdentifierScheme" => "ORCID" }.compact
        elsif ni["nameIdentifierScheme"] == "ROR"
          {
            "nameIdentifier" => normalize_ror(name_identifier),
            "schemeUri" => "https://ror.org",
            "nameIdentifierScheme" => "ROR" }.compact
        else
          {
            "nameIdentifier" => name_identifier,
            "schemeUri" => ni.fetch("schemeURI", nil),
            "nameIdentifierScheme" => ni["nameIdentifierScheme"] }.compact
        end
      end.presence

      { "nameType" => name_type,
                 "name" => name,
                 "givenName" => given_name,
                 "familyName" => family_name,
                 "nameIdentifiers" => name_identifiers,
                 "affiliation" => get_affiliations(author.fetch("affiliation", nil)),
                 "contributorType" => contributor_type }.compact
    end

    def cleanup_author(author)
      return nil unless author.present?

      # titleize strings
      # remove non-standard space characters
      author.gsub(/[[:space:]]/, ' ')
    end

    def is_personal_name?(author)
      return false if author.fetch("nameType", nil) == "Organizational"
      return true if Array.wrap(author.fetch("nameIdentifiers", nil)).find { |a| a["nameIdentifierScheme"] == "ORCID" }.present? ||
                     author.fetch("familyName", "").present? ||
                     (author.fetch("name", "").include?(",") &&
                     author.fetch("name", "").exclude?(";")) ||
                     name_exists?(author.fetch("name", "").split(" ").first)
      false
    end

    # recognize given name if we have loaded ::NameDetector data, e.g. in a Rails initializer
    def name_exists?(name)
      return false unless name_detector.present?

      name_detector.name_exists?(name)
    end

    # parse array of author strings into CSL format
    def get_authors(authors)
      Array.wrap(authors).map { |author| get_one_author(author) }.compact
    end

    def authors_as_string(authors)
      Array.wrap(authors).map do |a|
        if a["familyName"].present?
          [a["familyName"], a["givenName"]].join(", ")
        elsif a["type"] == "Person"
          a["name"]
        elsif a["name"].present?
          "{" + a["name"] + "}"
        end
      end.join(" and ").presence
    end

    def get_affiliations(affiliations)
      Array.wrap(affiliations).map do |a|
        affiliation_identifier = nil
        if a.is_a?(String)
          name = a.squish
          affiliation_identifier_scheme = nil
          scheme_uri = nil
        else
          scheme_uri = a["schemeURI"]
          if a["affiliationIdentifier"].present?
            affiliation_identifier = a["affiliationIdentifier"]
            if a["schemeURI"].present?
              schemeURI = a["schemeURI"].end_with?("/") ? a["schemeURI"] : a["schemeURI"] + "/"
            end
            affiliation_identifier = !affiliation_identifier.to_s.start_with?("https://") && schemeURI.present? ? normalize_id(schemeURI + affiliation_identifier) : normalize_id(affiliation_identifier)
            # The normalize_id(affiliation_identifier) method currently discards affiliation identifiers that don't start with a URL, 
            # for example: affiliation_identifier = "05bp8ka05".
            # To address this issue, we are introducing the following change to handle such affiliation identifiers.
            # when `normalize_id` method could not normalize, it returns nil, hence we have following condition
            if affiliation_identifier.nil?
              if a["affiliationIdentifierScheme"] == "ROR"
                affiliation_identifier = normalize_ror(a["affiliationIdentifier"])
              else
                affiliation_identifier = a["affiliationIdentifier"]
              end
            end
          end
          name = a["__content__"].to_s.squish.presence
          affiliation_identifier_scheme = a["affiliationIdentifierScheme"]
        end

        { "name" => name,
          "affiliationIdentifier" => affiliation_identifier,
          "affiliationIdentifierScheme" => affiliation_identifier_scheme,
          "schemeUri" => scheme_uri }.compact
      end.presence
    end
  end
end
