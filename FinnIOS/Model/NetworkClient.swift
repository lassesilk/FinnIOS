//
//  NetworkClient.swift
//  FinnIOS
//
//  Created by Lasse Silkoset on 07.03.2018.
//  Copyright © 2018 Lasse Silkoset. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NetworkClient
{
    let AD_URL = "https://gist.githubusercontent.com/3lvis/3799feea005ed49942dcb56386ecec2b/raw/63249144485884d279d55f4f3907e37098f55c74/discover.json"
    
    var imageURL: URL?
    
    //MARK: - JSON Fetch
    //**************************************************************************************************/
    
    enum Result<AdObject> {
        case Success(AdObject)
        case Error(String)
    }
    
    
    //loading the json with @escaping, so that the closure is escaping if invoked after the func returns
    func loadItemsFromJSON(completion: @escaping (Result<[AdObject]>) -> Void) {
        //Creating a temp array to use as a container.
        var itemsLoadedFromJSON = [AdObject]()
        if let url = URL(string: AD_URL) {
            let session = URLSession.shared
            let task = session.dataTask(with: url) { (data, response, error) in
                
                if data == nil {
                    completion(.Error("Was not able to retrieve data"))
                }
                
               guard let data = data else { return } 
               
                
                if error != nil {
                    print(error!)
                }
                
                do {
                    
                    let ads = try JSONDecoder().decode(AdJSON.self, from: data)
                    //Loading up an array of adObjects so it will be easier to handle when saving to core data.
                    for ad in ads.items {
                        itemsLoadedFromJSON.append(AdObject(adObjectImage: nil, adObjectDescription: ad.description, adObjectPrice: ad.price?.value, adObjectUrl: ad.image?.url, adObjectLocation: ad.location, adObjectId: ad.id, adObjectfavourited: false))
                    }
                    
                    DispatchQueue.main.async {
                        
                        completion(.Success(itemsLoadedFromJSON))
                        
                    }
                } catch {
                    print(error)
//
                }
            }
            task.resume()
        }
    }
    
    
    //MARK: - Image Fetch
    //**************************************************************************************************/
    
    enum Fetch<UIImage> {
        case Success(UIImage)
    }
    
    func loadImage(completion: @escaping (Fetch<UIImage>) -> Void) {
        if let url = imageURL {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error  in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else { return }
                //Checking if the application still needs the image before it is returned
                if url == self?.imageURL {
                  
                    DispatchQueue.main.async() {
                        completion(.Success(image))
                    }
                }
                
                }.resume()
        }
    }
    
}




