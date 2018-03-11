# FinnIOS

Update:

I have restructured the application using NSFetchedResultsController. My solution now consists of parsing a JSON at viewDidLoad, storing it temporarily in a local array, and then dispatching everything to core data. Then I manipulate a new attribute in Core Data, a bool thats called itemfavourited, via the didSelectItemAt method, and when the toogleSwitch gets pressed it deletes the items in Core Data with a boolean value of false. This gets interpreted from Core Data to the collectionView, via NSFetchedResultsControllerDelegate methods controllerDidChangeContent and didChange at indexPath. 

When the toogleSwitch gets pressed again, the appliaction fetches from JSON again, but before storing in core data it checks the itemID, to see if there are any possible duplicates. In other words, if the ad already exists in core data, it does not duplicate it. Thats because I wanted the object to still be able to keep track of their attributes itemfavourited(bool) and itemimage(NSData).

All values are still optional in case of unexpected nil-values. 

This time around I learned a lot! And I am really proud of the progress I have done in such a short period of time. I feel like I am on to something with this solution, but I am wondering if the Core Data methods maybe should have been in another class. 

If I had more time, I would like to point out something I would have liked to change. First of all, if the application already have 1000 items in Core Data at viewDidLoad, I should have not even performed the fetch from the JSON. At least not at the point of wich I am doing so. It is bad for the users dataplan, and it also contributes to a worse preformance overall. My ideal solution would have been to fetch data into the Collection View via a fetchResult predicate that limits the fetch to maybe 50 items, and then, when there was no more items left in Core Data to fetch, I would do a JSON fetch to see if there are any more items that has been added, that is, if it was dynamic. I am hoping to get some pointers on what I should have done to populate the collection view with a limited fetch.




----------------------------------------------------------------------------------------------------------------------------
Original solution:

My solution to this challenge is populating an array of objects with optional properties, and then reloading the collection view. When starting the application up, this array gets populated from a JSON file, via the adData() function and a decodable struct. adData decides wether or not the array gets populated by the result from the JSON file, or from the objects that are stored in core data, depending on a boolean value that tracks if the toggleSwitch is enabled or disabled.

If you enable the toggleSwitch, the application will clear the array and then go fetch objects from core data, if there are any. If you then disable it, it will clear the array again, and fetch items from the JSON file and re-pupulate the array with new objects.

I have chosen create all properties as optionals in case of unexpected nil-values in the JSON-file. And also because I use the same initalizer, wich I created in the class AdObject, to append objects from both datasources into the same array. That means that if I initialize from JSON, I am initalizing a url string for the image, and if I am doing it from core data I am doing it with a UIImage, so I am depending on being able to set the property to nil at some point.

If there is anything that I feel particularly proud of, it is the way I handled the JSON - file. Especially since it was nested the way it was. I have never parsed a JSON before without implementing cocoapods, like SwiftyJSON or Alamofire. But now I know how, so that is great!

I could have done a lot of things better. If you scroll really fast, you can see that the images are flickering, thats because of the reusable cells. And I think you can cause a bad memory-cycle as well, if you scroll fast and press the toggle switch. My plan was to send a url into a fetchImage() func, and then capture the url in a closure. And right before I dispatch to the main queue to update the UI, I was going to compare the url captured in the closure to the url outside. But I was not able to make it work in time, because the function gets called so many times from cellForItemAt.

I also could of made another view controller and passed the the data through a prepareForSegue function, and then made a protocol to keep track of the adHeart label and wich objects that are saved. If I would have done it this way, I probably could have returned at the indexes in the collection view I performed the segue from in the first place. It seems inefficent to reload the collection view with so many objects all the time, so maybe I should have manipulated the array instead.

When you have had your phone in flight mode and turned it off again, nothing happens when you open the application, unless you terminate the application completely and start over. So I should have added a observer to applicationDidBecomeActive, and then fetched the data again.

I am a little unsure of this, but I was wondering if I should do the fetching of data from other classes. The functions seems like they should be UI-independent.

The last thing I would have liked to do better is to use pagination to parse the JSON in smaller pieces.

If I would have had more time, I would have solved all of the issues above, and then teached myself how to comment properly.

I really enjoyed working on the project, and I learned a lot from doing so!
