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
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var lblRemoveImage: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var URLs = [String]()
    var mapPin: MapPin!
    
    var images_cache = [String:UIImage]()
    var deletedURL = [String]()
    var selectedIndexes = [IndexPath]()
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.delegate = self
        
        removeButton.setTitle("Add new collection", for: UIControlState.normal)
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: touristConstants.cellWidth, height: touristConstants.cellHeight)
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        self.mapView.delegate = self
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.navigationController?.isNavigationBarHidden = false
        self.setMapRegion()
        self.dropPin()
        
        if ( (mapPin.photos?.count)! > 0 ) {
            populateCollectionFromEntity()
        } else {
            downloadFlickrPhotosAndPopulateCollection()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.collectionView!.reloadData()
        mapView.reloadInputViews()
        self.mapView.reloadInputViews()
    }

    
    @IBAction func btnRemoveImage(_ sender: AnyObject) {
 
        //In case of new collection, full reload, clear entities
        if ( removeButton.currentTitle == "Add new collection") {
            deletedURL.removeAll()
            deleteAllPhotos()
            downloadFlickrPhotosAndPopulateCollection()
            return;
        }
        
        //Remove selected images
        for i in 0 ..< deletedURL.count {
            let url = deletedURL[i]
            URLs.remove(at: URLs.index(of: url)!)
            deletePhotofromEntity(url: url)
        }
        
        //Clear up deleted URL collection
        deletedURL.removeAll()
        removeButton.setTitle("Add new collection", for: UIControlState.normal)
        collectionView.reloadData()
    }
    
    func deletePhotofromEntity(url: String) {
        let context = CoreDataStackManager.sharedInstance().managedObjectContext!
        let photos = NSFetchRequest<Photos>(entityName: "Photos")
        let searchQuery = NSPredicate(format: "url = %@", argumentArray: [url])
        photos.predicate = searchQuery
        
        if let result = try? context.fetch(photos) {
            for object in result {
                context.delete(object)
            }
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print (error)
        }
    }
    
    func populateCollectionFromEntity() {
        
        for item in self.mapPin.photos! {
            self.URLs.append((item as! Photos).url!)
        }
        
        self.mapView.delegate = self
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.navigationController?.isNavigationBarHidden = false
        self.setMapRegion()
        self.dropPin()
        self.collectionView.reloadData()
        self.mapView.reloadInputViews()
        

    }
    
    func downloadFlickrPhotosAndPopulateCollection() {
        FlickrApi.sharedInstance.getPhotos(Double(mapPin.latitude), longitude: Double(mapPin.longitude)) { (result, error) in
            if let error = error {
                print(error)
            } else {
                DispatchQueue.main.async( execute: {
                    self.URLs = result!
                    self.collectionView.reloadData()
                    self.mapView.reloadInputViews()
                })
            }
        }
    }
    
    func deleteAllPhotos() {
        let context = CoreDataStackManager.sharedInstance().managedObjectContext!
        for item in self.mapPin.photos! {
            context.delete((item as! Photos))
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print (error)
        }
    }
    
    func configureCell(_ cell: UICollectionViewCell, atIndexPath indexPath: IndexPath) {
        _ = fetchResultsController.object(at: indexPath) as! Photos
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.URLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath as IndexPath)! as! CustomCollectionViewCell
        
        if ( cell.layer.borderColor == UIColor.yellow.cgColor ) {
            deletedURL.remove(at: deletedURL.index(of: cell.url)!)
            cell.layer.borderWidth = CGFloat(touristConstants.cellBorderWidth)
            cell.layer.borderColor = UIColor.black.cgColor
        } else {
            cell.layer.borderWidth = CGFloat(touristConstants.cellBorderWidth)
            cell.layer.borderColor = UIColor.yellow.cgColor
            deletedURL.append(cell.url)
        }
        
        if ( deletedURL.count == 0 ) {
            removeButton.setTitle("Add new collection", for: UIControlState.normal)
        } else {
            removeButton.setTitle("Remove Selected Pictures", for: UIControlState.normal)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        cell.layer.borderWidth = CGFloat(touristConstants.cellBorderWidth)
        cell.layer.borderColor = UIColor.black.cgColor
        
        let storedImage = isImageAlreadyinEntity(url: URLs[indexPath.row])
        
        if ( storedImage != nil ) {
            cell.imageView.image = storedImage
            cell.url = URLs[indexPath.row]
        } else {
            load_image(link: URLs[indexPath.row], cell: cell)
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
   
    func load_image(link:String, cell:CustomCollectionViewCell) {
        
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
                        cell.imageView.image = image
                        cell.url = link
                        
                        //Add photo entity
                        let context = CoreDataStackManager.sharedInstance().managedObjectContext!
                        let imageData: NSData? = UIImageJPEGRepresentation(image!, 0.6) as NSData?;
                        
                        let photo = Photos(image: imageData!, url: link,  context: context)
                        self.mapPin.addToPhotos(photo)
                        
                        photo.mapPin = self.mapPin
                        
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
    
    func dropPin() {
        let pinCoord = CLLocationCoordinate2D(latitude: mapPin.latitude, longitude: mapPin.longitude)
        let mapPointAnnotation = MKPointAnnotation()
        mapPointAnnotation.coordinate = pinCoord
        mapView.addAnnotation(mapPointAnnotation)
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
