require 'dotenv'
require 'uri'
require 'httparty'
require_relative 'rest'
class BusStop
    def initialize (busStop)
        @busStop = busStop;
        Dotenv.load(File.join(__dir__, '../.env'))
        key = ENV['TIH_BUS_API_KEY']
        @@headers = {
           "X-API-Key" => key
        }
        @restClient = Rest.new()
    end
    
    def getUniqueBuses
        response = @restClient.getBusesByBusStop(@busStop)
        if response["status"]["code"] == 200
            data = []
            uniqueBuses = []
            puts "Data retrieved successfully"
            while true
                response["data"].each do |service|
                    uniqueBuses << service["number"] unless uniqueBuses.include? service["number"]
                    data << service
                end
                unless response["paginationLinks"]["next"] 
                    break
                end
                response = @restClient.getNextPage(response["paginationLinks"]["next"])
            end
            puts "data length: %d" %[data.length()]    
        else
            puts "Failed"
        end
        return uniqueBuses, data        
    end
    def getBusArrival(service)
        response = @restClient.getBusArrivalByServiceAndStop(@busStop,service)
        arrivalTimes = {}
        if response["status"]["code"] == "200"
            i= 0
            response["data"].each do |arrival|
                arrivalTimes[i.to_s] = arrival["NextBus"]["EstimatedArrival"]
                i+=1
                if i == 3
                    break
                end
            end
        else
            puts "Failed to get arrival times"
        end
        return arrival = {"bus" => service, "timing" => arrivalTimes}
    end
    def getAllBusArrivals
        busList, _ = getUniqueBuses()
        allServices = {}
        busList.each do |bus|
            puts "bus " + bus.to_s
            arrival  = getBusArrival(bus)
            allServices[arrival["bus"]] = arrival["timing"]
        end
        return allServices
    end
end

busStopX = BusStop.new("10009")
puts busStopX.getAllBusArrivals()
