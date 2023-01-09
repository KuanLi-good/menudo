
import Foundation
import Alamofire
import SwiftUI

class AppConstants {
    static let APIURL = "http://127.0.0.1:4000",
               SERVERLESS_LAMBDA = "https://fh8y54lezj.execute-api.us-east-1.amazonaws.com/dev/",
               API_ENDPOINT = "https://c6b4cmguv2.execute-api.ap-southeast-2.amazonaws.com/uploads"

}
//         application/json vs application/x-www-form-urlencoded
//         {"Name": "John Smith", "Age": 23} vs Name=John+Smith&Age=23


class Serverless {
    static let shared = Serverless()
    
    
    func get_users(completion: @escaping (Result<[Seller], Error>) -> Void) {
        AF.request(URL.init(string: AppConstants.SERVERLESS_LAMBDA + "users")!,
                   method: .get,
                   encoding: JSONEncoding.default)
//        .responseString { response in
//            debugPrint("Response: \(response)")
//        }
        .responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    guard let users = try JSONSerialization.jsonObject(with: data) as? [Dictionary<String,Any>] else {
                       print("Error: Cannot convert data to JSON object")
                       return
                            
                   }
                    var sellerList:[Seller] = []
                    for seller in users {
                        let id = seller["user"] as? String
                        let name = seller["full_name"] as? String
                        let email = seller["email"] as? String
                        let restaurant_name = seller["restaurant_name"] as? String
                        let uuid_major = seller["uuid_major"] as? Int
                        
                        let seller = Seller(id: id ?? "", full_name: name ?? "", email: email ?? "", restaurant_name: restaurant_name ?? "", uuid_major: uuid_major ?? 0)
                        if seller.id.isEmpty || seller.uuid_major == 0 { continue }
                        sellerList.append(seller)
                    }
                    completion(.success(sellerList))
                    
                }catch {
                   print("Error: Trying to convert JSON data to string")
                   return
                }

                break
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }
    }
    
    
    func get_inventory(userId: String, completion: @escaping (Result<[Product], Error>) -> Void) {
        AF.request(URL.init(string: AppConstants.SERVERLESS_LAMBDA + "inventory/" + userId)!,
                   method: .get,
                   encoding: JSONEncoding.default)
//        .responseString { response in
//            debugPrint("Response: \(response)")
//        }
        .responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    guard let inventory = try JSONSerialization.jsonObject(with: data) as? [Dictionary<String,Any>] else {
                       print("Error: Cannot convert data to JSON object")
                       return
                            
                   }
                    var itemList:[Product] = []
                    for item in inventory {
                        let id = item["id"] as? String
                        let seller = item["seller"] as? String
                        let name = item["name"] as? String
                        let image = item["image"] as? String
                        let price = item["price"] as? Double
                        let item = Product(id: id ?? "", name: name ?? "", image: image ?? "", seller: seller ?? "", price: price ?? 0)
                        if item.id.isEmpty || item.name.isEmpty || item.price.isZero { continue }
                        itemList.append(item)
                    }
                    completion(.success(itemList))
                    
                }catch {
                   print("Error: Trying to convert JSON data to string")
                   return
                }

                break
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }
    }
    
    
    func send_order(with order: Order, completion: @escaping (Result<Void, Error>) -> Void) {
        let parameters = order.toParams
        AF.request(URL.init(string: AppConstants.SERVERLESS_LAMBDA + "send_order")!,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default)
//        .responseString { response in
//            print("Response String: \(String(describing: response.value))")
//        }
        .responseData { response in
            switch response.result {
            case .success(let data):
                do {
                guard let utf8Text = String(data: data, encoding: .utf8)else {
                    print("Error: Cannot convert data to String")
                    return
                }
                print("Data: \(utf8Text)")
                completion(.success(()))
                    
                }catch {
                   print("Error: Trying to convert JSON data to string")
                   return
                }
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }

    }
}

