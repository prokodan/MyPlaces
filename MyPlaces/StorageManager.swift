//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Данил Прокопенко on 18.10.2022.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {

    static let shared = StorageManager()
    
    private init() {}
    
     func saveObject(_ place: Place) {
        
        try! realm.write {
            realm.add(place)
        }
    }
    
    func deleteObject(_ place: Place) {
       
       try! realm.write {
           realm.delete(place)
       }
   }
    
    
}
