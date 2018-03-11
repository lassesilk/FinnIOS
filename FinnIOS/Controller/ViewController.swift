//
//  ViewController.swift
//  FinnIOS
//
//  Created by Lasse Silkoset on 25.02.2018.
//  Copyright © 2018 Lasse Silkoset. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate   {
    
    @IBOutlet weak var adCollectionView: UICollectionView!
    
    //An outlet on the switch because i want to force the application in favourite mode when offline
    @IBOutlet weak var toggle: UISwitch!
    //a variable to keep track of wether or not the switch has been pressed before updating the view
    var toggleGetsPressed = false
    
    //An array of blockOperations to communicate between Core Data and the Collection View.
    private var blockOperations = [BlockOperation]()
    
    //Context is used frequently, so i declared it as a global private let.
    private let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: AdFromCoreData.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "itemid", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        adCollectionView.delegate = self
        adCollectionView.dataSource = self
        
        setupNavigationBar()
        
        updateCollectionViewContent()
        
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
    
    @IBAction func toggleSwitch(_ sender: UISwitch) {
        if sender.isOn {
            //Deleting items with a bool value == false. Wich in turn updates the view with items that have a bool value == true
            toggleGetsPressed = true
            deleteItemsInCoreData()
            
            
        } else {
            
            updateCollectionViewContent()
        }
        
    }
    
    func showAlertWith(title: String, message: String, style: UIAlertControllerStyle = .alert) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: - CollectionView Content
    //**************************************************************************************************/
    
    
    //Calling this func at viewDidLoad and if toogleSwitch is switched to false
    private func updateCollectionViewContent() {
        
        do {
            
            //Doing a fetch to make sure the Collection View knows what to do at viewDidLoad.
            try self.fetchedhResultController.performFetch()
            
        } catch let error  {
            print("ERROR: \(error)")
        }
        
        let itemCount = fetchedhResultController.sections?[0].numberOfObjects
        
        let networking = NetworkClient()
        networking.loadItemsFromJSON { (result) in
            switch result {
            case .Success(let data):
                
                //Making sure that the Collection View does not load up twice, if there already is elements in Core Data at viewDidLoad.
                if itemCount != 0 {
                    for object in data {
                        let checkedItem = self.checkForItemInCoreData(id: object.id!)
                        if checkedItem == true {
                            //If user has pressed, it needs to repopulate the Collection View
                            if self.toggleGetsPressed == true {
                                self.deleteItemsInCoreData()
                                self.saveInCoreDataWith(array: data)
                                self.toggleGetsPressed = false
                            }
                            
                        } else {
                            //If items is not in Core Data, with favourited attribute, and toggle is pressed, it needs to delete and insert.
                            if self.toggleGetsPressed == true {
                                self.deleteItemsInCoreData()
                                self.saveInCoreDataWith(array: data)
                                self.toggleGetsPressed = false
                                return
                            } else {
                                //protects against loading twice
                                return
                            }
                        }
                    }
                } else {
                    //If there are 0 objects in core data at viewDidLoad, or the toggle is pressed.
                    self.saveInCoreDataWith(array: data)
                }
            case .Error(let message):
                print(message)
                self.deleteItemsInCoreData()
                
                DispatchQueue.main.async {
                    self.toggle.setOn(true, animated: true)
                    self.showAlertWith(title: "Error", message: message)
                }
            }
        }
    }
    
    //MARK: - CollectionView
    //**************************************************************************************************/
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let count = fetchedhResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "adCell", for: indexPath) as! CustomAdCell
        
        if let ad = fetchedhResultController.object(at: indexPath) as? AdFromCoreData {
            cell.setCustomAdCell(ad: ad)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CustomAdCell
        
        if let ad = fetchedhResultController.object(at: indexPath) as? AdFromCoreData {
            
            
            let existsInCoreData = checkForItemInCoreData(id: cell.adId!)
            //Making sure image is not already stored in Core Data
            if existsInCoreData == false {
                
                ad.itemimage = UIImagePNGRepresentation(cell.adImage.image!) as NSData?
                ad.itemfavourited = true
                saveContextToCoreData()
                cell.setCustomAdCell(ad: ad)
                
            } else {
                
                ad.itemimage = nil
                ad.itemfavourited = false
                saveContextToCoreData()
                cell.setCustomAdCell(ad: ad) 
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "adCell", for: indexPath) as! CustomAdCell
        
        cell.adImage.image = UIImage(named: "placeholder")
        
    }
    
    //MARK: - NSFetchedResultsController
    //**************************************************************************************************/
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            blockOperations.append(BlockOperation(block: {
                
                //Inserting items when fetching from JSON
                self.adCollectionView.insertItems(at: [newIndexPath!])
                
            }))
        case .delete:
            blockOperations.append(BlockOperation(block: {
                //Need this to change the attribute itemfavourited
                self.adCollectionView.deleteItems(at: [indexPath!])
            }))
            
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        adCollectionView.performBatchUpdates({
            
            for Operation in self.blockOperations {
                Operation.start()
            }
        }, completion: nil)
        
    }
    
    
    //MARK: - Core Data
    //**************************************************************************************************/
    
    
    private func createAdEntityFrom(adFromArray: AdObject) -> NSManagedObject? {
        //Checks if item already exists with attribute favourited
        let existsInCoreData = checkForItemInCoreData(id: adFromArray.id!)
        //Adds it to Core Data if it is not.
        if existsInCoreData == false {
            
            if let adEntity = NSEntityDescription.insertNewObject(forEntityName: "AdFromCoreData", into: context) as? AdFromCoreData {
                
                
                adEntity.itemdescription = adFromArray.description
                adEntity.itemid = adFromArray.id
                adEntity.itemlocation = adFromArray.location
                adEntity.itemurl = adFromArray.url
                adEntity.itemfavourited = adFromArray.favourited
                if let myInt: Int = adFromArray.price {
                    adEntity.itemprice = Int32(myInt)
                    
                }
                
                return adEntity
            }
        }
        return nil
    }
    
    private func saveInCoreDataWith(array: [AdObject]) {
        
        _ = array.map{self.createAdEntityFrom(adFromArray: $0)}
        
        saveContextToCoreData()
        
    }
    
    private func saveContextToCoreData() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    private func checkForItemInCoreData(id: String) -> Bool {
        
        let request: NSFetchRequest<AdFromCoreData> = NSFetchRequest(entityName: "AdFromCoreData")
        //Checking item via ID to see if favourited
        request.predicate = NSPredicate(format: "itemid == %@ AND itemfavourited == true", id)
        
        
        var imageExistsInCoreData = false
        
        do {
            let result = try context.fetch(request)
            imageExistsInCoreData = result.count > 0
            
        } catch {
            print(error)
        }
        
        return imageExistsInCoreData
    }
    
    private func deleteItemsInCoreData() {
        
        let request: NSFetchRequest<AdFromCoreData> = NSFetchRequest(entityName: "AdFromCoreData")
        request.predicate = NSPredicate(format: "itemfavourited == false")
        
        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            
        } catch {
            print(error)
        }
    }
   
    
}

