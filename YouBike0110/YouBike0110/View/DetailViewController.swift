//
//  DetailViewController.swift
//  YouBike0110
//
//  Created by change on 2022/1/11.
//

import UIKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController, CLLocationManagerDelegate {
    
    var youbike: YouBikeResponse!
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var navigate: UIButton!
    @IBOutlet weak var sarea: UILabel!
    @IBOutlet weak var sna: UILabel!
    @IBOutlet weak var ar: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setMap()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigate.layer.cornerRadius = 5
        mapView.layer.cornerRadius = 5
        
        youbike.sna.removeFirst(11)
        
        sarea.text = youbike.sarea
        sna.text = youbike.sna
        ar.text = youbike.ar
    }
    
    
    
    @IBAction func navigate(_ sender: Any) {
        navigateMap()
        
    }
    
    func setMap(){
        // 開啟APP會詢問使用權限
        if CLLocationManager.authorizationStatus()  == .notDetermined {
            // 取得定位服務授權
            locationManager.requestWhenInUseAuthorization()
            // 開始定位自身位置
            locationManager.startUpdatingLocation()
        }
        
        
        let location = CLLocation(latitude: youbike.lat, longitude: youbike.lng)
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        
        var objectAnnotation = MKPointAnnotation()
        
        // 建立另一個地點圖示 (經由委任方法設置圖示)
        objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = CLLocation(
            latitude: youbike.lat,
            longitude: youbike.lng).coordinate
        objectAnnotation.title = youbike.sna
        objectAnnotation.subtitle = youbike.ar
        mapView.addAnnotation(objectAnnotation)
    }
    
    func navigateMap(){
        //目標經維度
        let targetLocation = CLLocationCoordinate2D(latitude: youbike.lat, longitude: youbike.lng)
        //透過地target Location建立一個MKMapItem
        let targetPlacemark = MKPlacemark(coordinate: targetLocation)
        // 目標地圖項目
        let targetItem = MKMapItem(placemark: targetPlacemark)
        
        
        let userMapItem = MKMapItem.forCurrentLocation()
        //建構路徑
        let routes = [userMapItem,targetItem]
        //呼叫openMaps方法開啟系統地圖 這邊設定開車
        MKMapItem.openMaps(with: routes, launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        
    }
}

