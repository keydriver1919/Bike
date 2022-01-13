//
//  ViewController.swift
//  YouBike0110
//
//  Created by change on 2022/1/10.
//

import UIKit
import CoreLocation

public var urlString = "https://tcgbusfs.blob.core.windows.net/dotapp/youbike/v2/youbike_immediate.json"

class ViewController: UIViewController, CLLocationManagerDelegate  { 
    
    var youbike = [YouBikeResponse]()
    lazy var filteredYoubike = youbike
    
    var locationManager = CLLocationManager()
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegment: UISegmentedControl!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 取得自身定位位置的精確度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus()  == .notDetermined {
            // 詢問使用者是否同意給APP定位功能
            locationManager.requestWhenInUseAuthorization()
            // 開始定位自身位置
            locationManager.startUpdatingLocation()
        }
        sortClose()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFileData()
        search()
        refresh()
        
        YouBikeClient.shared.getYouBike(urlString: urlString) { youbikes in
            
            if let youbikes = youbikes {
                self.youbike = youbikes
                YouBikeResponse.saveToFile(records: youbikes)
            }
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        //因為ＧＰＳ功能很耗電,所以背景執行時關閉定位功能
        locationManager.stopUpdatingLocation()
    }
    
    
    
    
    @IBAction func sortSegment(_ sender: Any) {
        sortClose()
        tableView.reloadData()
    }
    
    
    func sortClose(){
        let myPoint = CLLocation(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0)
        
        switch sortSegment.selectedSegmentIndex {
        case 0:
            filteredYoubike.sort(by: { $0.location.distance(from: myPoint) <  $1.location.distance(from: myPoint)})
        case 1:
            filteredYoubike.sort(by: { $0.location.distance(from: myPoint) >  $1.location.distance(from: myPoint)})
        default:
            print("sortSegment錯誤")
        }
    }
    
    
    func search(){
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func refresh(){
        //將元件加入TableView的視圖中
        tableView.addSubview(refreshControl)
        //將loadData方法加到refresh
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
    }
    
    
    // 取得儲存的資料
    func getFileData() {
        guard let data = YouBikeResponse.readDrinkDataFromFile() else { return }
        youbike = data
    }
    
    @IBSegueAction func show(_ coder: NSCoder) -> DetailViewController? {
        if let row = tableView.indexPathForSelectedRow?.row{
            let controller = DetailViewController(coder: coder)
            controller?.youbike = youbike[row]
            return controller
        }else{
            return nil
        }
        
    }
    
    
    //刷新
    @objc func loadData() {
        // 模擬網路延遲
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            //            停止讀取動畫
            self.refreshControl.endRefreshing()
            
            let urlStr = urlString
            if let url = URL(string: urlStr) {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    let decoder = JSONDecoder()
                    if let data = data {
                        do {
                            let youbike = try decoder.decode([YouBikeResponse].self, from: data)
                            self.youbike = youbike
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        } catch  {
                            print(error)
                        }
                    }
                }.resume()
            }
        }
    }
}



extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredYoubike.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        var filteredYoubike = filteredYoubike[indexPath.row]
        //刪除前面youbike的字
        filteredYoubike.sna.removeFirst(11)
        
        let myPoint = CLLocation(latitude: locationManager.location?.coordinate.latitude ?? 20, longitude: locationManager.location?.coordinate.longitude ?? 20)
        let goalPoint = CLLocation(latitude: filteredYoubike.lat, longitude: filteredYoubike.lng)
        let distance = goalPoint.distance(from: myPoint)/1000
        
        cell.distance.text = "\(distance)"
        cell.label.text = filteredYoubike.sna
        cell.tot.text = "\(filteredYoubike.tot)"
        cell.bemp.text = "\(filteredYoubike.bemp)"
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}


extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text,
           searchText.isEmpty == false  {
            filteredYoubike = youbike.filter({ youbike in
                youbike.sna.localizedStandardContains(searchText)
            })
        } else {
            filteredYoubike = youbike
        }
        tableView.reloadData()
    }
}


