//
//  MapPhotoCollectionViewController.swift
//  Virtual Tourist v2
//
//  Created by Arif Khan on 10/5/16.
//  Copyright © 2016 Snnab. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData
import Photos


class MapPhotoCollectionViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var lblRemoveImage: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var URLs = [String]()
    var mapPin: MapPin!
    
    var images_cache = [String:UIImage]()
    
    var count = 0
    
    var selectedIndexes = [IndexPath]()
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        lblRemoveImage.isHidden = true
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 120) //CGSizeMake(120,120)
        self.collectionView.setCollectionViewLayout(layout, animated: true)
        
        FlickrApi.sharedInstance.getPhotos(Double(mapPin.latitude), longitude: Double(mapPin.longitude)) { (result, error) in
            if let error = error {
                print(error)
            } else {
                self.mapView.delegate = self
                self.collectionView.delegate = self
                self.collectionView.dataSource = self
                self.navigationController?.isNavigationBarHidden = false
                self.URLs = result!
                self.setMapRegion()
                self.collectionView.reloadData()
                //self.loadImages()

            }
        }
        
        
        //do {
        //    try fetchResultsController.performFetch()
        //} catch let error as NSError {
        //    print(error)
        //}
    }
    
    func configureCell(_ cell: UICollectionViewCell, atIndexPath indexPath: IndexPath) {
        let photo = self.fetchResultsController.object(at: indexPath) as! Photos
    }

    func loadImages () {
        
        var point = CGPoint(x: 0, y: 0)
        var indexPath = collectionView.indexPathForItem(at: point)
        let cell = collectionView.cellForItem(at: indexPath!)
        cell?.backgroundColor = UIColor.blue
        
       /* downloadImage(imagePath: self.URLs[0], completionHandler: { (imageData, errorString) -> Void in
         
         self.count = self.count + 1
         if ( self.count == self.URLs.count) {
         print ("count equals exiting now")
         return;
         }
         
         cell.imageView.image = UIImage(data:imageData!,scale:1.0)
         let context = CoreDataStackManager.sharedInstance().managedObjectContext!
         let photo = Photos(image: imageData! as NSData,  context: context)
         
         self.mapPin.addToPhotos(photo)
         
         do {
         try context.save()
         } catch let error as NSError {
         print (error)
         }
         }) */

    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.URLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        lblRemoveImage.isHidden = false
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
       /* let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        
        print ("arif" + String(describing: indexPath))
        print(indexPath)
        
        cell.imageView.image = #imageLiteral(resourceName: "loading")
        return cell*/
        
        /*downloadImage(imagePath: self.URLs[(indexPath as NSIndexPath).item], completionHandler: { (imageData, errorString) -> Void in

            self.count = self.count + 1
            if ( self.count == self.URLs.count) {
                print ("count equals exiting now")
                return;
            }
            
            cell.imageView.image = UIImage(data:imageData!,scale:1.0)
            let context = CoreDataStackManager.sharedInstance().managedObjectContext!
            let photo = Photos(image: imageData! as NSData,  context: context)
            
            self.mapPin.addToPhotos(photo)
            
            do {
                try context.save()
            } catch let error as NSError {
                print (error)
            }
        }) */
        
        //let cell:CellClass = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CellClass
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        
        
        if (images_cache[self.URLs[indexPath.row]] != nil)
        //if (images_cache[images[indexPath.row]] != nil)
        {
            cell.imageView.image = images_cache[self.URLs[indexPath.row]]
            //cell.Image.image = images_cache[images[indexPath.row]]
        }
        else
        {
            load_image(link: self.URLs[indexPath.row], imageview:cell.imageView)
            //load_image(images[indexPath.row], imageview:cell.Image)
        }
        
        return cell
        
    }
    
    
    func load_image(link:String, imageview:UIImageView)
    {
        
       // let url:NSURL = NSURL(string: link)!
       // let session = NSURLSession.sharedSession()
        
       // let request = NSMutableURLRequest(URL: url)
       // request.timeoutInterval = 10
        
        
       // let task = session.dataTaskWithRequest(request) {
       //     (
       //     data, response, error) in
            
       //     guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                
       //         return
       //     }
            
            
       //     var image = UIImage(data: data!)
            
       //     if (image != nil)
       //     {
                
                
        //        func set_image()
        //        {
        //            self.images_cache[link] = image
        //            imageview.image = image
        //        }
                
                
        //        dispatch_async(dispatch_get_main_queue(), set_image)
                
        //    }
            
        //}
        
        //task.resume()
        
        //----
        
        let session = URLSession.shared
        let imgURL = NSURL(string: link)
        let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
        
        let task = session.dataTask(with: request as URLRequest) {data, response, downloadError in
            
            if downloadError != nil {
                //completionHandler(nil, "Could not download image \(imagePath)")
                print ("Could not download image \(link)")
            } else {
                
                //completionHandler(data, nil)
                
                var image = UIImage(data: data!)
                if (image != nil)
                {
                    func set_image()
                    {
                        self.images_cache[link] = image
                        imageview.image = image
                    }
                    //DispatchQueue.main.asynchronously(execute: set_image)
                    
                    DispatchQueue.main.async( execute: {
                        set_image()
                    })
                }
            }
        }
        task.resume()
    }
    
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        //let rect = CGRectMake(0, 0, size.width, size.height)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func downloadImage( imagePath:String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void){
        
        print(imagePath)
        let session = URLSession.shared
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
        
        let task = session.dataTask(with: request as URLRequest) {data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(nil, "Could not download image \(imagePath)")
            } else {
                
                completionHandler(data, nil)
            }
        }
        
        task.resume()
    }
    
  
    
    func populateImageAsyn (cell: CustomCollectionViewCell, indexPath: IndexPath ) {
        
        print("map pin")
        print((indexPath as NSIndexPath).item)
        
        DispatchQueue.global().async {
        
            DispatchQueue.main.async {
                //check if image has already been loaded
                //if ( self.mapPinSave.photos?.count == self.URLs.count ) {
                //    print("load loading image from saved entity")
                //    let photo = (self.mapPinSave.photos?.allObjects as! [Photos])[(indexPath as NSIndexPath).item]
                //    cell.imageView.image = UIImage(data:photo.image as! Data,scale:1.0)
                //} else {
                
                    let url = URL(string: self.URLs[(indexPath as NSIndexPath).item])
                    let data = NSData(contentsOf: url!)
                
                    let image = UIImage(data: data! as Data)
                    let imageData: NSData? = UIImageJPEGRepresentation(image!, 0.6) as NSData?;
                    let context = CoreDataStackManager.sharedInstance().managedObjectContext!
                
                    let mapPins = NSFetchRequest<MapPin>(entityName: "MapPin")
                
                    let mapPinFetch = NSFetchRequest<MapPin>(entityName: "MapPin")
                
                do {
                    let fetchedPins = try context.fetch(mapPinFetch as! NSFetchRequest<NSFetchRequestResult>) as! [MapPin]
                    print ("test")
                } catch {
                    print ("Failed to fetch")
                }
                
                    let searchQuery = NSPredicate(format: "latitude = %@ AND longitude = %@", argumentArray: [self.mapPin.latitude, self.mapPin.longitude])
                    mapPins.predicate = searchQuery
                
                    if let result = try? context.fetch(mapPins) {
                        for object in result {
                            let photo = Photos(image: imageData!,  context: context)
                            (object as MapPin).addToPhotos(photo)
                            cell.imageView.image = UIImage(data:photo.image as! Data,scale:1.0)
                            
                            self.count = self.count + 1
                            print(self.count)
                        }
                    }
                
                    //let photo = Photos(image: imageData!,  context: context)
                    //print ("add photo to the location")
                    //self.mapPinSave.addToPhotos(photo)
                    //cell.imageView.image = UIImage(data:photo.image as! Data,scale:1.0)
                
                    do {
                        try context.save()
                    } catch let error as NSError {
                        print (error)
                    }
                //}
            }
        }
    }
    
    func setMapRegion() {
        let latitude:CLLocationDegrees = mapPin.latitude
        let longitude:CLLocationDegrees = mapPin.longitude 
        let latDelta:CLLocationDegrees = 1.99
        let lonDelta:CLLocationDegrees = 1.99
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: false)
    }
    
    lazy var fetchResultsController: NSFetchedResultsController<MapPin> = {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MapPin")
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController.delegate = self
        return fetchResultsController as! NSFetchedResultsController<MapPin>
    }()
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
        print("in controllerWillChangeContent")
    }
    
    // The second method may be called multiple times, once for each Color object that is added, deleted, or changed.
    // We store the incex paths into the three arrays.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type{
            
        case .insert:
            print("Insert an item")
            // Here we are noting that a new Color instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            print("Delete an item")
            // Here we are noting that a Color instance has been deleted from Core Data. We keep remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            print("Update an item.")
            // We don't expect Color instances to change after they are created. But Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an images is downloaded from
            // Flickr in the Virtual Tourist app
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
            }, completion: nil)
    }
}
