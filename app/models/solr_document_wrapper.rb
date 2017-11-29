class SolrDocumentWrapper <
 attr_reader :timestamp

 def initialize(search_service)
   @timestamp = 'timestamp'
   @search_service = search_service
 end


  def earliest
    (deprecated_response,records) = @search_service.search_result do |builder|
      builder = {fl: @timestamp, sort: "#{@timestamp} asc", rows: 1}
    end
    records.first.timestamp
  end

 def latest
   (deprecated_response,records) = @search_service.search_result do |builder|
     builder = {fl: @timestamp, sort: "#{@timestamp} desc", rows: 1}
   end
   records.first.timestamp
 end


end