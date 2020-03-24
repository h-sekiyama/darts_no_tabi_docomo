import UIKit

class ViewController: UIViewController {
    
    var name: String?

    @IBOutlet weak var stationName: UILabel!
    @IBAction func dartsButton(_ sender: Any) {
        stationName.text = name
        getStationName()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getStationName()
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
            } catch {
                print(error)
            }
        })
        task.resume()
    }

}

