//
//  Run.swift
//  Treads
//
//  Created by NGUYENLONGTIEN on 6/9/20.
//  Copyright © 2020 NGUYENLONGTIEN. All rights reserved.
//

import Foundation
import RealmSwift
let config = Realm.Configuration(
    schemaVersion: 1,
    migrationBlock: { migration, oldSchemaVersion in
        if (oldSchemaVersion < 1) {
            // Nothing to do!
            // Realm will automatically detect new properties and removed properties
            // And will update the schema on disk automatically
        }
})

class Run:Object{
    @objc dynamic public private(set) var id = ""
    @objc dynamic public private(set) var date = Date()
    @objc dynamic public private(set) var pace = 0.0
    @objc dynamic public private(set) var distance = 0.0
    @objc dynamic public private(set) var duration = 0
    var locations = List<Location>()
    
    override class func primaryKey() -> String {
        return "id"
    }
    override class func indexedProperties() -> [String] {
        return ["date"]
    }
    convenience init(pace:Double, distance:Double, duration:Int, locations:List<Location>) {
        self.init()
        self.id = UUID().uuidString.lowercased()
        self.date = Date()
        self.pace = pace
        self.duration = duration
        self.distance = distance
        self.locations = locations
    }
    
    
    static func addRunToRealm(pace:Double, duration:Int, distance:Double, location:List<Location>){
        let run = Run(pace: pace, distance: distance, duration: duration, locations:location)
        do{
            let realm = try Realm(configuration: config)
            try realm.write{
                realm.add(run)
                try realm.commitWrite()
                //
                NotificationCenter.default.post(name: NOTIF_RUD_DATA_DID_CHANGE, object: nil)
                print("Add run to realm sucessfully")
            }
        }catch{
            debugPrint("Error adding run to realm \(error)")
        }
//        REALM_QUEUE.async {
//            
//        }
    }
    //
    static func getAllRunFromRealm() -> Results<Run>?{
        do{
            let realm = try Realm(configuration: config)
            var runs = try realm.objects(Run.self)
            runs = runs.sorted(byKeyPath: "date", ascending: false)
            return runs
        }catch{
            return nil
        }
    }
    static func deleteRunObjectFromRealm(run:Run, completionHandler: @escaping (_ success: Bool)->Void){
        do{
            let realm = try Realm(configuration: config)
            try realm.write{
                realm.delete(run)
                completionHandler(true)
            }
        }catch{
            print("Can not delete")
            completionHandler(false)
        }
    }
    
    
    
    
    
    
    
}

