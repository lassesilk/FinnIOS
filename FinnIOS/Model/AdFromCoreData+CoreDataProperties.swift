//
//  AdFromCoreData+CoreDataProperties.swift
//  FinnIOS
//
//  Created by Lasse Silkoset on 07.03.2018.
//  Copyright © 2018 Lasse Silkoset. All rights reserved.
//
//

import Foundation
import CoreData


extension AdFromCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AdFromCoreData> {
        return NSFetchRequest<AdFromCoreData>(entityName: "AdFromCoreData")
    }

    @NSManaged public var itemdescription: String?
    @NSManaged public var itemid: String?
    @NSManaged public var itemimage: NSData?
    @NSManaged public var itemlocation: String?
    @NSManaged public var itemprice: Int32
    @NSManaged public var itemurl: String?
    @NSManaged public var itemfavourited: Bool

}
