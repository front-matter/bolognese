# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as csv" do
    it "with data citation" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      csv = (subject.csv).parse_csv
      
      expect(csv[0]).to eq("10.7554/elife.01567")
      expect(csv[1]).to eq("https://elifesciences.org/articles/01567")
      expect(csv[2]).to eq("2014")
      expect(csv[3]).to eq("article")
      expect(csv[4]).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(csv[5]).to eq("Sankar, Martial and Nieminen, Kaisa and Ragni, Laura and Xenarios, Ioannis and Hardtke, Christian S")
      expect(csv[6]).to eq("(:unav)")
      expect(csv[7]).to eq("eLife")
    end

    it "with pages" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      csv = (subject.csv).parse_csv

      expect(csv[0]).to eq("10.1155/2012/291294")
      expect(csv[1]).to eq("http://www.hindawi.com/journals/pm/2012/291294/")
      expect(csv[2]).to eq("2012")
      expect(csv[3]).to eq("article")
      expect(csv[4]).to eq("Delineating a Retesting Zone Using Receiver Operating Characteristic Analysis on Serial QuantiFERON Tuberculosis Test Results in US Healthcare Workers")
      expect(csv[5]).to eq("Thanassi, Wendy and Noda, Art and Hernandez, Beatriz and Newell, Jeffery and Terpeluk, Paul and Marder, David and Yesavage, Jerome A.")
      expect(csv[6]).to eq("(:unav)")
      expect(csv[7]).to eq("Pulmonary Medicine")
      expect(csv[10]).to eq("1-7")
    end

    it "text" do
      input = "https://doi.org/10.17173/PRETEST8"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.valid?).to be true
      csv = (subject.csv).parse_csv

      expect(csv[0]).to eq("10.17173/pretest8")
      expect(csv[1]).to eq("http://pretest.gesis.org/Pretest/DoiId/10.17173/pretest8")
      expect(csv[2]).to eq("2014")
      expect(csv[3]).to eq("article")
      expect(csv[4]).to eq("PIAAC-Longitudinal (PIAAC-L) 2015")
      expect(csv[5]).to eq("Lenzner, T. and Neuert, C. and Otto, W. and Landrock, U. and Menold, N.")
      expect(csv[6]).to eq("GESIS – Pretest Lab")
    end

    it "climate data" do
      input = "https://doi.org/10.5067/altcy-tj122"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.valid?).to be true
      csv = (subject.csv).parse_csv

      expect(csv[0]).to eq("10.5067/altcy-tj122")
      expect(csv[1]).to eq("http://podaac.jpl.nasa.gov/dataset/MERGED_TP_J1_OSTM_OST_CYCLES_V2")
      expect(csv[2]).to eq("2012")
      expect(csv[3]).to eq("misc")
      expect(csv[4]).to eq("Integrated Multi-Mission Ocean Altimeter Data for Climate Research Version 2")
      expect(csv[5]).to eq("{GSFC}")
      expect(csv[6]).to eq("NASA Physical Oceanography DAAC")
    end
    
    it "maremma" do
      input = "https://github.com/datacite/maremma"
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      csv = (subject.csv).parse_csv

      expect(csv[0]).to eq("10.5438/qeg0-3gm3")
      expect(csv[1]).to eq("https://github.com/datacite/maremma")
      expect(csv[2]).to eq("2017")
      expect(csv[3]).to eq("misc")
      expect(csv[4]).to eq("Maremma: a Ruby library for simplified network calls")
      expect(csv[5]).to eq("Fenner, Martin")
      expect(csv[6]).to eq("DataCite")
      expect(csv[12]).to eq("faraday, excon, net/http")
    end
  end
end