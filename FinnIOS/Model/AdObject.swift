//
//  AdObject.swift
//  FinnIOS
//
//  Created by Lasse Silkoset on 24.02.2018.
//  Copyright © 2018 Lasse Silkoset. All rights reserved.
//

import Foundation
import UIKit

class AdObject {
    
    let image: UIImage?
    let description: String?
    let price: Int?
    let url: String?
    let location: String?
    let id: String?
    let favourited: Bool
    
    
    init(adObjectImage: UIImage?, adObjectDescription: String?, adObjectPrice: Int?, adObjectUrl: String?, adObjectLocation: String?, adObjectId: String?, adObjectfavourited: Bool) {
        image = adObjectImage
        description = adObjectDescription
        price = adObjectPrice
        url = adObjectUrl
        location = adObjectLocation
        id = adObjectId
        favourited = adObjectfavourited
        
       
    }
}
