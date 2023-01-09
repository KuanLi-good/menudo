//
//  User.swift
//  MenudoAdmin
//
//  Created by kuan on 1/11/22.
//

import Foundation
import SwiftUI

struct User: Codable{
    var id: String
    var email: String?
    var full_name: String?
    var restaurant_name: String?
    var uuid_major = Int.random(in: 1..<999)
    var toParams: [String: Any] {
            return [
                "user" : id as Any,
                "full_name" : full_name as Any,
                "email" : email as Any,
                "restaurant_name" : restaurant_name as Any,
                "uuid_major": uuid_major as Any
            ]
    }
    
    
    init(id: String, full_name: String?, email: String?) {
        self.id = id
        self.full_name = full_name
        self.email = email
    }
    
    init(id: String, full_name: String?, email: String?, restaurant_name: String?) {
        self.id = id
        self.full_name = full_name
        self.email = email
        self.restaurant_name = restaurant_name
    }
    
    init(id: String, full_name: String?, email: String?, restaurant_name: String?, uuid_major: Int) {
        self.id = id
        self.full_name = full_name
        self.email = email
        self.restaurant_name = restaurant_name
        self.uuid_major = uuid_major
    }
    
    init() {
        self.id = ""
    }
    

}

extension User: CustomDebugStringConvertible {
    var debugDescription: String {
        return """
        ID: \(id)
        Name: \(String(describing: full_name))
        Email: \(String(describing: email))
        Restaurant Name: \(String(describing: restaurant_name))
        UUID Major: \(uuid_major)
        """
    }
}


//extension User: Codable {
//  enum CodingKeys: String, CodingKey {
//    case id
//    case email
//    case full_name
//    case restaurant_name
//    case uuid_major
//
//  }
//
//  init(from decoder: Decoder) throws {
//    let values = try decoder.container(keyedBy: CodingKeys.self)
//    id = try values.decode(String.self, forKey: .id)
//    email = try values.decode(String.self, forKey: .email)
//    full_name = try values.decode(String.self, forKey: .full_name)
//    restaurant_name = try values.decode(String.self, forKey: .restaurant_name)
//    uuid_major = try values.decode(Int.self, forKey: .uuid_major)
//  }
//
//  func encode(to encoder: Encoder) throws {
//    var container = encoder.container(keyedBy: CodingKeys.self)
//    try container.encode(id, forKey: .id)
//    try container.encode(email, forKey: .email)
//    try container.encode(full_name, forKey: .full_name)
//    try container.encode(restaurant_name, forKey: .restaurant_name)
//    try container.encode(uuid_major, forKey: .uuid_major)
//  }
//}
