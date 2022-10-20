//
//  Place.swift
//  MyPlaces
//
//  Created by Данил Прокопенко on 17.10.2022.
//

import RealmSwift
import UIKit

class Place: Object {
    
    @Persisted var name = ""
    @Persisted var location: String?
    @Persisted var type: String?
    @Persisted var imageData: Data?
    @Persisted var date = Date()
    @Persisted var rating = 0.0

    convenience init(name: String, location: String?, type: String?, imageData: Data?, rating: Double) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
    }
    
//     let restarauntNames = ["Балкан Гриль", "Бочка", "Вкусные истории", "Дастархан", "Индокитай", "Классик", "Шок", "Bonsai", "Burger Heroes", "Kitchen", "Love&Life", "Morris Pub", "Sherlock Holmes", "Speak Easy", "X.O"]
//
//    func savePlaces() {
//
//
//        for place in restarauntNames {
//            let image = UIImage(named: place)
//            guard let imageData = image?.pngData() else {return}
//
//            let newPlace = Place()
//            newPlace.name = place
//            newPlace.location = "Ufa"
//            newPlace.type = "Restaurant"
//            newPlace.imageData = imageData
//
//            StorageManager.shared.saveObject(newPlace)
//        }
//
//
//    }
    
}
