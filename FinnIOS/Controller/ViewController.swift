//
//  ViewController.swift
//  FinnIOS
//
//  Created by Lasse Silkoset on 25.02.2018.
//  Copyright © 2018 Lasse Silkoset. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var adCollectionView: UICollectionView!
    private var adObjectArray = [AdObject]()
    private var toggleSwitchIsOn = false
    
    
    private let AD_URL = "https://gist.githubusercontent.com/3lvis/3799feea005ed49942dcb56386ecec2b/raw/63249144485884d279d55f4f3907e37098f55c74/discover.json"
    private let baseImageURL = "https://images.finncdn.no/dynamic/480x360c/"
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        adCollectionView.delegate = self
        adCollectionView.dataSource = self
        
        setupNavigationBar()
        
        //Calling a function to load up collectionview with JSON or CoreData
        adData()
        
    }
    
    //MARK: - UI
    //**************************************************************************************************/
    
    private func setupNavigationBar() {
    
    let titleLabel = UILabel(frame: CGRect(x: 0,y: 0,width: view.frame.width - 32,height: view.frame.height))
    titleLabel.text = "Kun favoritter"
    navigationItem.titleView = titleLabel
    
    }
  
    
    //MARK: - Action Event
    //**************************************************************************************************/
    
    //Needs to clear the array and repopulate depending on where the user wants to fetch data from
    @IBAction func toggleSwitch(_ sender: UISwitch) {
        
        switch sender.isOn {
        case true:
            toggleSwitchIsOn = true
            adObjectArray.removeAll()
            adData()
        case false:
            toggleSwitchIsOn = false
            adObjectArray.removeAll()
            adData()
        }
    }
    
  
    
    //MARK: - CollectionVew
    //**************************************************************************************************/
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return adObjectArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Needs to cast constant to access custom made cell outlets.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "adCell", for: indexPath) as! CustomAdCell
        
        cell.adDescription.isHidden = true
        cell.adPrice.isHidden = true
        cell.adLocation.isHidden = true
        
        let adObject = adObjectArray[indexPath.item]
        
        //If let on all items in case nil-value.
        
        if let itemDescription = adObject.description {
            cell.adDescription.text = itemDescription
            cell.adDescription.isHidden = false
        }
        
        if let itemPrice = adObject.price {
            
            cell.adPrice.text = ("\(itemPrice),-")
            cell.adPrice.sizeToFit()
            cell.adPrice.isHidden = false
            
        }
        
        if let itemLocation = adObject.location {
            
            cell.adLocation.text = itemLocation
            cell.adLocation.isHidden = false
            
        }
        
        //Cell Image needs to know where to fetch data. Either pre-fetched image in Core data or from URLSession in extension.
        if adObject.image != nil {
            cell.adImage.image = adObject.image!
            
        } else if adObject.url != nil {
            
            let imageURL = baseImageURL + (adObject.url)!
            cell.adImage.downloadedFrom(link: imageURL)
            
        } else {
            
            cell.adImage.isHidden = true
        }
        
        cell.adId = adObject.id!
        
       //Hooking up label to ID to avoid reuse in cells, and remember wich ones are selected when toggling.
        if checkIdInCoreData(id: cell.adId!) == true {
            cell.adHeart.text = "♥︎"
            cell.adHeart.textColor = UIColor.white
        } else {
            cell.adHeart.text = "♡"
            cell.adHeart.textColor = UIColor.white
        }

        return cell
    }
    
   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CustomAdCell
    
    //calls function to check if we need to save or delete the ad
        let existsInCoreData = checkIdInCoreData(id: cell.adId!)
        
        if existsInCoreData == false {
            
            cell.adHeart.text = "♥︎"
            cell.adHeart.textColor = UIColor.white
            
            let adObject = AdFromCoreData(context: context)
            
            adObject.itemdescription = cell.adDescription.text
            adObject.itemprice = (cell.adPrice.text! as NSString).intValue
            adObject.itemlocation = cell.adLocation.text
            adObject.itemimage = UIImagePNGRepresentation(cell.adImage.image!)
            adObject.itemid = cell.adId
            
            saveItemsInCoreData()
        
            } else {
            
            cell.adHeart.text = "♡"
            cell.adHeart.textColor = UIColor.white
            
            deleteItemsInCoreData(id: cell.adId!)
            saveItemsInCoreData()
            if toggleSwitchIsOn == true {
                adObjectArray.remove(at: indexPath.item)
                adCollectionView.reloadData()
            }
        }
    }
    
    //MARK: - Load up data
    /**************************************************************************************************/
    
    //Created to work as a "Central Dispatch".
    private func adData() {
        if toggleSwitchIsOn == false {
            loadItemsFromJSON()
        }
        else {
            adObjectArray = loadItemsFromCoreData()
        }
        adCollectionView.reloadData()
    }
    
    func recieveObjectsFromJSON(loadedArray: [AdObject]) {
        adObjectArray = loadedArray
        adCollectionView.reloadData()
    }
    
    
    //MARK: - Networking
    /**************************************************************************************************/
    
    private func loadItemsFromJSON() {
        //Creating a temp array to use as a container on another queue.
        var itemsLoadedFromJSON = [AdObject]()
        if let url = URL(string: AD_URL) {
            let session = URLSession.shared
            let task = session.dataTask(with: url) { (data, response, error) in
                guard let data = data else { return }
                
                if error != nil {
                   print(error!)
                }
                
                do {
                    let ads = try JSONDecoder().decode(AdJSON.self, from: data)
                    
                    for ad in ads.items {
                        itemsLoadedFromJSON.append(AdObject(adObjectImage: nil, adObjectDescription: ad.description, adObjectPrice: ad.price?.value, adObjectUrl: ad.image?.url, adObjectLocation: ad.location, adObjectId: ad.id))
                    }
                    //assigning to main, to do UI-stuff.
                    DispatchQueue.main.async {
                        self.recieveObjectsFromJSON(loadedArray: itemsLoadedFromJSON)
                    }
                } catch {
                    print(error)
                }
            }
            task.resume()
        }
    }
    
    
    
    
    //MARK: - Core Data
    /**************************************************************************************************/
    
    private func saveItemsInCoreData() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
//    Returns Array to separate assignments
    private func loadItemsFromCoreData() -> [AdObject] {
        
        let request: NSFetchRequest<AdFromCoreData> = AdFromCoreData.fetchRequest()
        var CoreDataArray = [AdFromCoreData]()
        var tempAdArray = [AdObject]()
        do {

            CoreDataArray =  try context.fetch(request)
            for ad in CoreDataArray {
                
                tempAdArray.append(AdObject(adObjectImage: UIImage(data: ad.itemimage!), adObjectDescription: ad.itemdescription, adObjectPrice: Int(ad.itemprice), adObjectUrl: nil, adObjectLocation: ad.itemlocation, adObjectId: ad.itemid))
            }

        } catch {
            print("Error fetching from context \(error)")
        }
        return tempAdArray
    }
    
    //Argument is id so we know it has a value if it exists in core data.
    private func deleteItemsInCoreData(id: String) {
        let request: NSFetchRequest<AdFromCoreData> = NSFetchRequest(entityName: "AdFromCoreData")
        request.predicate = NSPredicate(format: "itemid == %@", id)

        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }

        } catch {
            print(error)
        }
    }
    
    //Argument is id so we know it has a value if it exists in core data.
    private func checkIdInCoreData(id: String) -> Bool {
        
        let request: NSFetchRequest<AdFromCoreData> = NSFetchRequest(entityName: "AdFromCoreData")
        request.predicate = NSPredicate(format: "itemid == %@", id)
        
        var adExistsInCoreData = false
        
        do {
            let result = try context.fetch(request)
            adExistsInCoreData = result.count > 0
            
        } catch {
            print(error)
        }
        
        return adExistsInCoreData
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFill) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

