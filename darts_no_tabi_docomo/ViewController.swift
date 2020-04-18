import UIKit

class ViewController: UIViewController {
    
    var name: String?
    var latitude: String = ""
    var longitude:String = ""
    
    @IBOutlet weak var angeno: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    var pickerView: UIPickerView = UIPickerView()
    
    // 県リスト
    var list: [String] = []
    let prefectureCodeArray = PrefectureCodeArray()
    
    var maxCount: Int = 660
    
    var prefectureCode: String = "13"
    
    // APIから受け取った座標が微妙にずれてるので、調整済みかどうか管理する
    var adjustmentFlag: Bool = false

    @IBOutlet weak var stationName: UILabel!
    @IBAction func dartsButton(_ sender: Any) {
        getStationName()
    }
    @IBOutlet weak var googleMapButtonImage: UIButton!
    @IBAction func googleMapButton(_ sender: Any) {
        if (!adjustmentFlag) {
            latitude = String(Double(latitude)! + 0.0032506)
            longitude = String(Double(longitude)! - 0.0032088)
            adjustmentFlag = true
        }
        let urlString: String!
        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
            urlString = "comgooglemaps://?q=\(latitude),\(longitude)&zoom=24"
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
        
        // 行き先を選んでない状態ではMapボタンは非アクティブ
        googleMapButtonImage.isEnabled = false
        googleMapButtonImage.imageView?.image = UIImage(named: "map_off")!
        
        // 都道府県選択ピッカーに入れる値を取得（先に都道府県コードでソート）
        let sortedPrefectureArray = prefectureCodeArray.prefectureKeyValue.sorted{ $0.value < $1.value }
        for (key, _) in sortedPrefectureArray {
            list.append(key)
            
        }
        
        // アンジュノアニメーションがバックグラウンドから復帰時も呼ばれる様にする
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(self.animationAngeno),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        // 背景画像のリピート
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "pattern.png")!)
        
        // ピッカー設定
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        // インプットビュー設定
        textField.inputView = pickerView
        textField.inputAccessoryView = toolbar
        
        // デフォルト設定
        pickerView.selectRow(0, inComponent: 0, animated: false)
    }
    
    @objc func animationAngeno() {
        let data = try! Data(contentsOf: URL(string: "https://i.gyazo.com/216d896e385ee9039362d11194a493b4.gif")!)
        angeno.animateGIF(data: data) {
            print("再生完了")
        }
    }
    
    // 決定ボタン押下
    @objc func done() {
        textField.endEditing(true)
        textField.text = "\(list[pickerView.selectedRow(inComponent: 0)])"
    }
    
    private func updateStation() {
        DispatchQueue.main.async {
            self.stationName.text = self.name
        }
    }

    // 駅情報を取得
    private func getStationName() {
        let rand: Int = Int.random(in: 0..<maxCount + 1)
        let url: URL = URL(string: "https://api.apigw.smt.docomo.ne.jp/ekispertCorp/v1/station?APIKEY=3536347a307777544266735a4b33304e4a633854617a78713653704a62332e497538532e526b3451562e2e&type=train&prefectureCode=\(prefectureCode)&limit=1&offset=\(rand)")!
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
                DispatchQueue.main.async {
                    self.googleMapButtonImage.isEnabled = true
                    self.googleMapButtonImage.imageView?.image = UIImage(named: "map")!
                    self.adjustmentFlag = false
                }
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    
    // 各県の駅数を取得
    private func getPrefectureData() {
        let url: URL = URL(string: "https://api.apigw.smt.docomo.ne.jp/ekispertCorp/v1/station?APIKEY=3536347a307777544266735a4b33304e4a633854617a78713653704a62332e497538532e526b3451562e2e&type=train&prefectureCode=\(prefectureCode)")!
        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            // コンソールに出力
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
                let resultSet = json["ResultSet"] as! [String: Any]
                let maxCountString: String = resultSet["max"]  as! String
                self.maxCount = Int(maxCountString)!
            } catch {
                print(error)
            }
        })
        task.resume()
    }
}

extension ViewController : UIPickerViewDelegate, UIPickerViewDataSource {
 
    // ドラムロールの列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // ドラムロールの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    // ドラムロールの各タイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    // ドラムロール選択時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.textField.text = list[row]
        
        if let prefectureCodeInt: Int = prefectureCodeArray.prefectureKeyValue[list[row]] {
            prefectureCode = String(prefectureCodeInt)
        } else {
            prefectureCode = "13"
        }
        getPrefectureData()
    }
}
