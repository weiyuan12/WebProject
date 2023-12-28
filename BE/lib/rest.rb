require 'dotenv'
require 'uri'
require 'httparty'
class Rest
    def initialize 
        Dotenv.load(File.join(__dir__, '../.env'))
        key = ENV['TIH_BUS_API_KEY']
        @@headers = {
           "X-API-Key" => key
        }
    end
    def getNextPage (uri)
        response = HTTParty.get(uri, headers: @@headers)
        return response
    end
    def getBusesByBusStop(busStop)
        uri = "https://api.stb.gov.sg/services/transport/v2/bus-services/bus-stop/#{busStop}?limit=50"
        response = HTTParty.get(uri, headers: @@headers)
        return response
    end
    def getBusArrivalByServiceAndStop(busStop,service)
        puts "Calling bus arrival timing"
        uri = "https://api.stb.gov.sg/services/transport/v2/bus-arrival/#{busStop}/#{service}"
        response = HTTParty.get(uri, headers: @@headers)
    end
end
