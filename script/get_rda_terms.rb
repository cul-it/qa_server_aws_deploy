# One-off script to fetch rda terms from RDA Reference value vocabularies: https://www.rdaregistry.info/termList/
# To run: ruby script/get_rda_terms.rb

require 'nokogiri'
require 'open-uri'

rda_vocabularies = [
  { href: "AspectRatio", title: "RDA Aspect Ratio Designation" },
  { href: "bookFormat", title: "RDA Bibliographic Format" },
  { href: "broadcastStand", title: "RDA Broadcast Standard" },
  { href: "RDACarrierEU", title: "RDA Carrier Extent Unit" },
  { href: "RDACarrierType", title: "RDA Carrier Type" },
  { href: "RDACartoDT", title: "RDA Cartographic Data Type" },
  { href: "RDACollectionAccrualMethod", title: "RDA Collection Accrual Method" },
  { href: "RDACollectionAccrualPolicy", title: "RDA Collection Accrual Policy" },
  { href: "RDAColourContent", title: "RDA Colour Content" },
  { href: "configPlayback", title: "RDA Configuration of Playback Channels" },
  { href: "RDAContentType", title: "RDA Content Type" },
  { href: "RDAExtensionPlan", title: "RDA Extension Plan" },
  { href: "fileType", title: "RDA File Type" },
  { href: "fontSize", title: "RDA Font Size" },
  { href: "MusNotation", title: "RDA Form of Musical Notation" },
  { href: "noteMove", title: "RDA Form of Notated Movement" },
  { href: "TacNotation", title: "RDA Form of Tactile Notation" },
  { href: "formatNoteMus", title: "RDA Format of Notated Music" },
  { href: "frequency", title: "RDA Frequency" },
  { href: "RDAGeneration", title: "RDA Generation" },
  { href: "groovePitch", title: "RDA Groove Pitch of an Analog Cylinder" },
  { href: "grooveWidth", title: "RDA Groove Width of an Analog Disc" },
  { href: "IllusContent", title: "RDA Illustrative Content" },
  { href: "RDAInteractivityMode", title: "RDA Interactivity Mode" },
  { href: "layout", title: "RDA Layout" },
  { href: "RDALinkedDataWork", title: "RDA Linked Data Work" },
  { href: "RDAMaterial", title: "RDA Material" },
  { href: "RDAMediaType", title: "RDA Media Type" },
  { href: "ModeIssue", title: "RDA Mode of Issuance" },
  { href: "RDAPolarity", title: "RDA Polarity" },
  { href: "presFormat", title: "RDA Presentation Format" },
  { href: "RDAproductionMethod", title: "RDA Production Method" },
  { href: "recMedium", title: "RDA Recording Medium" },
  { href: "RDARecordingMethods", title: "RDA Recording Methods" },
  { href: "RDARecordingSources", title: "RDA Recording Source" },
  { href: "RDAReductionRatio", title: "RDA Reduction Ratio Designation" },
  { href: "RDARegionalEncoding", title: "RDA Regional Encoding" },
  { href: "scale", title: "RDA Scale Designation" },
  { href: "soundCont", title: "RDA Sound Content" },
  { href: "specPlayback", title: "RDA Special Playback Characteristics" },
  { href: "statIdentification", title: "RDA Status of Identification" },
  { href: "RDATerms", title: "RDA Terms" },
  { href: "trackConfig", title: "RDA Track Configuration" },
  { href: "RDATypeOfBinding", title: "RDA Type of Binding" },
  { href: "typeRec", title: "RDA Type of Recording" },
  { href: "RDAUnitOfTime", title: "RDA Unit of Time" },
  { href: "RDATasks", title: "RDA User Tasks" },
  { href: "videoFormat", title: "RDA Video Format" }
]

rda_vocabularies.each do |v|
  new_filename = "#{v[:title].downcase.gsub(/\s+/, '_')}.yml"
  doc = Nokogiri::XML(URI.open("https://www.rdaregistry.info/xml/termList/#{v[:href]}.xml"))
  File.open("config/authorities/#{v[:title].downcase.gsub(/\s+/, '_')}.yml", 'w') do |f|
    terms_yml = ":terms:\n"
    concepts = doc.xpath("//rdf:RDF//skos:Concept")
    raise "No concepts found for #{v}" if concepts.count == 0
    concepts.map do |concept|
      uri = concept["rdf:about"]
      # id = uri.split("/")[-1]
      term = concept.at_xpath("skos:prefLabel[@xml:lang='en']").text

      raise "Missing info for #{v}" if uri.empty? || term.empty?
      if uri.include?("termList")
        terms_yml += "    - :id: #{uri}\n"
        terms_yml += "      :uri: #{uri}\n"
        terms_yml += "      :term: #{term}\n"
      else
        puts "Skipping uri: #{uri}"
      end
    end
    f.write(terms_yml)
  end
  puts "Created #{new_filename}"
end
