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
    
    //var count = 0
    
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
            }
        }
    }
    
    func configureCell(_ cell: UICollectionViewCell, atIndexPath indexPath: IndexPath) {
        let photo = self.fetchResultsController.object(at: indexPath) as! Photos
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.URLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        lblRemoveImage.isHidden = false
        let cell = collectionView.cellForItem(at: indexPath as IndexPath)
     
        cell?.layer.borderWidth = 2.0
        cell?.layer.borderColor = UIColor.yellow.cgColor
    }
    
   
    
    private func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        lblRemoveImage.isHidden = false
        let cell = collectionView.cellForItem(at: indexPath as IndexPath)
        cell?.layer.borderWidth = 2.0
        cell?.layer.borderColor = UIColor.gray.cgColor
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        cell.imageView.layer.borderWidth = 1.0
        cell.imageView.layer.borderColor = UIColor.black.cgColor
        
        let storedImage = isImageAlreadyinEntity(url: self.URLs[indexPath.row])
        
        if ( storedImage != nil ) {
            cell.imageView.image = storedImage
        } else {
            load_image(link: self.URLs[indexPath.row], imageview:cell.imageView)
        }
        
        return cell
    }
    
    func isImageAlreadyinEntity (url: String) -> UIImage? {
        
        let context = CoreDataStackManager.sharedInstance().managedObjectContext!
        let photos = NSFetchRequest<Photos>(entityName: "Photos")
        let searchQuery = NSPredicate(format: "url = %@", argumentArray: [url])
        photos.predicate = searchQuery
        
        if let result = try? context.fetch(photos) {
            for object in result {
                let image = UIImage(data: (object as Photos).image as! Data)
                return image!
            }
        }
        return nil
    }
    
    func load_image(link:String, imageview:UIImageView) {
        
        let session = URLSession.shared
        let imgURL = NSURL(string: link)
        let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
        
        let task = session.dataTask(with: request as URLRequest) {data, response, downloadError in
            
            if downloadError != nil {
                print ("Could not download image \(link)")
            } else {
                
                var image = UIImage(data: data!)
                if (image != nil)
                {
                    func set_image()
                    {
                        self.images_cache[link] = image
                        imageview.image = image
                        
                        //Add photo entity
                        let context = CoreDataStackManager.sharedInstance().managedObjectContext!
                        let imageData: NSData? = UIImageJPEGRepresentation(image!, 0.6) as NSData?;
                        
                        let photo = Photos(image: imageData!, url: link,  context: context)
                        self.mapPin.addToPhotos(photo)
                        
                        do {
                            try context.save()
                        } catch let error as NSError {
                            print (error)
                        }
                        
                    }
                    DispatchQueue.main.async( execute: {
                        set_image()
                    })
                }
            }
        }
        task.resume()
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
