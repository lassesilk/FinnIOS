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
    
    let netClient = NetworkClient()
    
    func setCustomAdCell(ad: AdFromCoreData) {
        
        DispatchQueue.main.async {
            
            self.adLocation.isHidden = true
            self.adDescription.isHidden = true
            self.adPrice.isHidden = true
            
            if let itemDescription = ad.itemdescription {
                self.adDescription.text = itemDescription
                self.adDescription.isHidden = false
            }
            
            if let itemLocation = ad.itemlocation {
                
                self.adLocation.text = itemLocation
                self.adLocation.isHidden = false
                
            }
            
            let itemPrice = ad.itemprice
            if itemPrice == 0 {
                self.adPrice.isHidden = true
            } else {
                self.adPrice.text = ("\(itemPrice),-")
                self.adPrice.sizeToFit()
                self.adPrice.isHidden = false
            }
            
            self.adId = ad.itemid
            
            //Change imagesource if favourited, so it can be marked with a heart
            if ad.itemimage != nil {
                self.adImage.image = UIImage(data: ad.itemimage! as Data)
                self.adHeart.text = "♥︎"
                self.adHeart.textColor = UIColor.white
            } else {
                
                let baseImageURL = "https://images.finncdn.no/dynamic/480x360c/"
                if let endURL = ad.itemurl {
                    let finalURL = baseImageURL + endURL
                    
                    let url = URL(string: finalURL)
                    self.netClient.imageURL = url
                    
                    self.netClient.loadImage { (fetch) in
                        switch fetch {
                        case .Success(let data):
                            
                            self.adImage.image = data
                            self.adHeart.text = "♡"
                            self.adHeart.textColor = UIColor.white
                            
                            
                        }
                    }
                }
            }
        }
    }
    
}
