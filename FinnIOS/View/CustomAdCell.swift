//
//  CustomAdCell.swift
//  FinnIOS
//
//  Created by Lasse Silkoset on 25.02.2018.
//  Copyright © 2018 Lasse Silkoset. All rights reserved.
//

import UIKit

class CustomAdCell: UICollectionViewCell {
    
    @IBOutlet weak var adImage: UIImageView!
    @IBOutlet weak var adLocation: UILabel!
    @IBOutlet weak var adDescription: UILabel!
    @IBOutlet weak var adPrice: UILabel!
    @IBOutlet weak var adHeart: UILabel!
    
    var adId: String?
    
}
