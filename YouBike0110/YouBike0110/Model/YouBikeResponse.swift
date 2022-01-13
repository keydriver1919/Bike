//
//  File.swift
//  YouBike0110
//
//  Created by change on 2022/1/10.
//

import Foundation
import CoreLocation


struct YouBikeResponse: Codable {
    var sna: String//站名
    var tot: Int//總數
    var bemp: Int//現在數量
    var sarea: String//區域
    var ar: String//位置
    var aren: String//地址
    var lat: Double//經度
    var lng: Double//緯度
    
    
    //排序計算用
    var location: CLLocation{
        return CLLocation(latitude: lat, longitude: lng)
    }
    
    
    //儲存一個臨時擋
    static func saveToFile(records: [YouBikeResponse]) {
        print("儲存一個臨時擋")
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(records) {
            // 產生一個UserDefaults物件
            let userDefault = UserDefaults.standard
            userDefault.set(data, forKey: "records")
        }
    }
    
    static func readDrinkDataFromFile() -> [YouBikeResponse]? {
        print("讀取臨時擋")
        let userDefaults = UserDefaults.standard
        let decoder = JSONDecoder()
        if let data = userDefaults.data(forKey: "records"),
           let records = try? decoder.decode([YouBikeResponse].self, from: data) {
            return records
        } else {
            return nil
        }
    }
}




