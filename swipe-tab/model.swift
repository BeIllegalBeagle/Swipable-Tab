//
//  model.swift
//  swipe-tab
//
//  Created by Peter Ajayi on 28/06/2020.
//  Copyright © 2020 Mito.P. All rights reserved.
//

import Foundation

class TabItems: Equatable {
  
    var name: String
    var order: Int
    var image: String
    var hashValue: Int
    var hidden: Bool
    
    init(name: String, order: Int, image: String, hidden: Bool, hashValue: Int) {
        self.name = name
        self.order = order
        self.image = image
        self.hidden = hidden
        self.hashValue = hashValue
    }
    
//    static func setOrder(items: [TabItems]){
//        
//           if let data = try? PropertyListEncoder().encode(items) {
//               UserDefaults.standard.set(data, forKey: "tabItems")
//           }
//    }
//    
//    static func getItems() -> [TabItems] {
//        let defaults = UserDefaults.standard
//        if let data = defaults.data(forKey: "tabItems") {
//            let array = try! PropertyListDecoder().decode([TabItems].self, from: data)
//            return array
//        }
//        return []
//    }
    
    static func == (lhs: TabItems, rhs: TabItems) -> Bool {
           return lhs.name == rhs.name// && lhs.image == rhs.image
      }
}
