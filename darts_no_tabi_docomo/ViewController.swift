import UIKit

class ViewController: UIViewController {
    
    var name: String?
    var latitude: String = ""
    var longitude:String = ""

    @IBOutlet weak var stationName: UILabel!
    @IBAction func dartsButton(_ sender: Any) {
        getStationName()
    }
    @IBAction func googleMapButton(_ sender: Any) {
//        latitude = "35.692096424393867"
//        longitude = "139.77235727788792"
        let urlString: String!
        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
            urlString = "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=walking&zoom=14"
            }
        else {
            urlString = "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=w"
            }
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
            }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func updateStation() {
        DispatchQueue.main.async {
            self.stationName.text = self.name
        }
    }

    private func getStationName() {
        let rand: Int = Int.random(in: 0..<661)
        let url: URL = URL(string: "https://api.apigw.smt.docomo.ne.jp/ekispertCorp/v1/station?APIKEY=3536347a307777544266735a4b33304e4a633854617a78713653704a62332e497538532e526b3451562e2e&type=train&prefectureCode=13&limit=1&offset=\(rand)")!
        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            // コンソールに出力
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
                let resultSet = json["ResultSet"] as! [String: Any]
                let point = resultSet["Point"] as! [String: Any]
                let stationData = point["Station"] as! [String: String]
                self.name = stationData["Name"]
                
                let getPoint = point["GeoPoint"] as! [String: String]
                self.latitude = getPoint["lati_d"]!
                self.longitude = getPoint["longi_d"]!
                self.updateStation()
            } catch {
                print(error)
            }
        })
        task.resume()
    }

}

