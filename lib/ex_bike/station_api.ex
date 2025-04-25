defmodule ExBike.StationAPI do
  @ecobici_api "https://gbfs.mex.lyftbikes.com/gbfs/en/station_information.json"

  def get_stations do
    response = Req.get!(@ecobici_api)
    body = Jason.decode!(response.body)
    body["data"]["stations"]
  end
end
