defmodule ExBike.StationAPI do
  @ecobici_api "https://gbfs.mex.lyftbikes.com/gbfs/en"

  def get_stations do
    response = Req.get!("#{@ecobici_api}/station_information.json")
    body = Jason.decode!(response.body)
    body["data"]["stations"]
  end

  def get_stations_updates do
    response = Req.get!("#{@ecobici_api}/station_status.json")
    body = Jason.decode!(response.body)
    body["data"]["stations"]
  end
end
