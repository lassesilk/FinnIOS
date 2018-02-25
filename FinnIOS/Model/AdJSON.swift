//
//  Ad.swift
//  parseJSON
//
//  Created by Lasse Silkoset on 15.02.2018.
//  Copyright © 2018 Lasse Silkoset. All rights reserved.
//

import Foundation


struct AdJSON: Decodable {
   let items: [Item]

    
    struct Item: Decodable {
        let image: Image?
        let id: String
        let description: String?
        let location: String?
        let price: Price?
        
    }

    struct Image: Decodable {
        let url: String?
    }

    struct Price: Decodable {
        let value: Int?
        }

    }


