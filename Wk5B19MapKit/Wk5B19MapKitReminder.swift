//
//  Wk5B19MapKitReminder.swift
//  Wk5B19MapKit
//
//  Created by Leonardo Lee on 8/21/14.
//  Copyright (c) 2014 Leonardo Lee. All rights reserved.
//

import Foundation
import CoreData

class Wk5B19MapKitReminder: NSManagedObject {

    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var message: String

}
