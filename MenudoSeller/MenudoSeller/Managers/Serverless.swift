// https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
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
    @AppStorage("token") var token: String = ""
    @AppStorage("userId") var userId: String = ""
    static let shared = Serverless()
    
    func register_if_not_exist(with user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        let parameters = user.toParams
        AF.request(URL.init(string: AppConstants.SERVERLESS_LAMBDA + "register_if_not_exist")!,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default)
        .responseData { response in
            switch response.result {
            case .success(let data):
                do {
                   guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? Dictionary<String,Any> else {
                       print("Error: Cannot convert data to JSON object")
                       return
                            
                   }
                    // add authentication token to headers
                    self.token = jsonObject["token"] as? String ?? ""
                    print(self.token)
                    
                    completion(.success(()))
                    
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
    
    func me(completion: @escaping (Result<User, Error>) -> Void) {
        if (self.token.isEmpty) {completion(.failure("No auth token" as! Error))}
        AF.request(URL.init(string: AppConstants.SERVERLESS_LAMBDA + "me")!,
                   method: .get,
                   encoding: JSONEncoding.default,
                   headers: HTTPHeaders(["Authorization": self.token]))
        .responseData { response in
            switch response.result {
            case .success(let data):
                do {
                   guard let userDict = try JSONSerialization.jsonObject(with: data) as? Dictionary<String,Any> else {
                       print("Error: Cannot convert data to JSON object")
                       return
                            
                   }
                    let full_name = userDict["full_name"] as? String
                    let user = userDict["user"] as? String
                    let email = userDict["email"] as? String
                    let restaurant_name = userDict["restaurant_name"] as? String
                    let uuid_major = userDict["uuid_major"] as? Int
                    let login_user = User(id: user ?? "s", full_name: full_name, email: email, restaurant_name: restaurant_name, uuid_major: uuid_major!)
                    completion(.success(login_user))
                    
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
    
    
    func get_inventory(completion: @escaping (Result<[Product], Error>) -> Void) {
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
                        let name = item["name"] as? String
                        let image = item["image"] as? String
                        let price = item["price"] as? Double
                        let item = Product(id: id ?? "", name: name ?? "", image: image ?? "", price: price ?? 0)
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
    
    
    func get_orders(completion: @escaping (Result<[Order], Error>) -> Void) {
        if (self.token.isEmpty) {completion(.failure("No auth token" as! Error))}
        AF.request(URL.init(string: AppConstants.SERVERLESS_LAMBDA + "orders/")!,
                   method: .get,
                   encoding: JSONEncoding.default,
                   headers: HTTPHeaders(["Authorization": self.token]))
        .responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    guard let orders = try JSONSerialization.jsonObject(with: data) as? [Dictionary<String,Any>] else {
                       print("Error: Cannot convert data to JSON object")
                       return
                            
                   }
                    var orderList:[Order] = []
                    for order in orders {
                        let id = order["id"] as? String
                        let seller = order["seller"] as? String
                        let items = order["items"] as? [String]
                        let total_price = order["total_price"] as? Double
                        let customer = order["customer"] as? String
                        let order = Order(id: id ?? "", seller: seller ?? "", items: items ?? [], total_price: total_price ?? 0, customer: customer ?? "")
                        if order.id.isEmpty || order.seller.isEmpty || order.customer.isEmpty || order.items.isEmpty || order.total_price.isZero { continue }
                        orderList.append(order)
                    }
                    completion(.success(orderList))
                    
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
    
    
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        self.token = ""
        completion(.success(()))
    }
    
    
    func edit_profile(with user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        if (self.token.isEmpty) {completion(.failure("No auth token" as! Error))}
        let parameters = user.toParams
        AF.request(URL.init(string: AppConstants.SERVERLESS_LAMBDA + "edit_profile")!,
                   method: .put,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: HTTPHeaders(["Authorization": self.token]))
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
    
    func delete_item(with itemId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if (self.token.isEmpty) {completion(.failure("No auth token" as! Error))}
        AF.request(URL.init(string: AppConstants.SERVERLESS_LAMBDA + "delete_item/" + itemId)!,
                   method: .delete,
                   encoding: JSONEncoding.default,
                   headers: HTTPHeaders(["Authorization": self.token]))
        .responseString { response in
            print("Response String: \(String(describing: response.value))")
        }
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
    
    
    func complete_order(with orderId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if (self.token.isEmpty) {completion(.failure("No auth token" as! Error))}
        AF.request(URL.init(string: AppConstants.SERVERLESS_LAMBDA + "complete_order/" + orderId)!,
                   method: .delete,
                   encoding: JSONEncoding.default,
                   headers: HTTPHeaders(["Authorization": self.token]))
        .responseString { response in
            print("Response String: \(String(describing: response.value))")
        }
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
    
    func upload_item(with item: Product, completion: @escaping (Result<Void, Error>) -> Void) {
        if (self.token.isEmpty) {completion(.failure("No auth token" as! Error))}
        let parameters = item.toParams
        AF.request(URL.init(string: AppConstants.SERVERLESS_LAMBDA + "upload_item")!,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: HTTPHeaders(["Authorization": self.token]))
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

