//
//  File.swift
//  YouBike0110
//
//  Created by change on 2022/1/11.
//

import Foundation
import UIKit


public class YouBikeClient {
    
    static var shared = YouBikeClient()
    
    func getYouBike(urlString: String, completionHandler: @escaping ([YouBikeResponse]?) -> ()) {
        if let url = URL(string: urlString){
            URLSession.shared.dataTask(with: url) { (data, respose, error) in
                let decoder = JSONDecoder()
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
                    let data = try decoder.singleValueContainer().decode(String.self)
                    return dateFormatter.date(from: data) ?? Date()
                })
                if let data = data {
                    do {
                        _ = try decoder.decode([YouBikeResponse].self, from: data)
                    } catch {
                        print(error)
                    }
                    let youbike = try? decoder.decode([YouBikeResponse].self, from: data)
                    completionHandler(youbike)
                }else{
                    completionHandler(nil)
                }
            }.resume()
        }
    }
}
