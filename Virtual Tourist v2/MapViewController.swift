//
//  MapViewController.swift
//  Virtual Tourist v2
//
//  Created by Arif Khan on 10/5/16.
//  Copyright © 2016 Snnab. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblDeletePin: UILabel!
    @IBAction func btnEditPin(_ sender: AnyObject) {
        
        if ( ((sender as! UIBarButtonItem).title) == "Edit" ) {
            lblDeletePin.isHidden = false
            (sender as! UIBarButtonItem).title = "Done"
        } else {
            lblDeletePin.isHidden = true
            (sender as! UIBarButtonItem).title = "Edit"
        }
    }
    
    func deletePin(viewAnnottion: MKAnnotationView) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let latitutde = viewAnnottion.annotation?.coordinate.latitude
        let longitude = viewAnnottion.annotation?.coordinate.longitude
        
        let mapPins = NSFetchRequest<MapPin>(entityName: "MapPin")
        let searchQuery = NSPredicate(format: "latitude = %@ AND longitude = %@", argumentArray: [latitutde, longitude])
        mapPins.predicate = searchQuery
            
        if let result = try? context.fetch(mapPins) {
                for object in result {
                    context.delete(object)
                }
        }
        mapView.removeAnnotation(viewAnnottion.annotation!)
        
        do {
            try context.save()
        } catch let error as NSError {
            print (error)
        }
    }
    
    @IBOutlet weak var btnEditPin: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.mapView.delegate = self
        
        //Add long press for users
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.AddPin(_:)))
        longPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPress)
        
        //Load from stored entity
        fetchPins()
        
        //Set map region
        setMapRegion()
        
        lblDeletePin.isHidden = true
        
        let context = CoreDataStackManager.sharedInstance().managedObjectContext!
        
        let mapPinFetch = NSFetchRequest<MapPin>(entityName: "MapPin")
        
        do {
            let fetchedPins = try context.fetch(mapPinFetch as! NSFetchRequest<NSFetchRequestResult>) as! [MapPin]
        } catch {
            print ("Failed to fetch")
        }
    }
    
    func setMapRegion() {
        let latitude:CLLocationDegrees = constLatitude
        let longitude:CLLocationDegrees = contLongitude
        let latDelta:CLLocationDegrees = constLatDelta
        let lonDelta:CLLocationDegrees = constLonDelta
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view:MKAnnotationView) {
    
        let context = CoreDataStackManager.sharedInstance().managedObjectContext!
        let latitutde = view.annotation?.coordinate.latitude
        let longitude = view.annotation?.coordinate.longitude

        if ( lblDeletePin.isHidden == false) {
            let mapPins = NSFetchRequest<MapPin>(entityName: "MapPin")
            let searchQuery = NSPredicate(format: "latitude = %@ AND longitude = %@", argumentArray: [latitutde!, longitude!])
            mapPins.predicate = searchQuery
         
            if let result = try? context.fetch(mapPins) {
                for object in result {
                    context.delete(object)
                }
            }
            mapView.removeAnnotation(view.annotation!)
            
            do {
                try context.save()
            } catch let error as NSError {
                print (error)
            }
            return;
        }
        
        let mapPins = NSFetchRequest<MapPin>(entityName: "MapPin")
        let searchQuery = NSPredicate(format: "latitude = %@ AND longitude = %@", argumentArray: [latitutde!, longitude!])
        mapPins.predicate = searchQuery
        var selectedMapPin : MapPin!
        
        if let result = try? context.fetch(mapPins) {
            for object in result {
                selectedMapPin = object as MapPin
            }
        }
        
        let oViewController = self.storyboard!.instantiateViewController(withIdentifier: "MapPhotoCollectionViewController") as! MapPhotoCollectionViewController
        oViewController.mapPin = selectedMapPin
        oViewController.mapView = mapView
        self.navigationController!.pushViewController(oViewController, animated: true)
    }
    
    //Add pin on the map when user holds the long press
    var mapPointAnnotation = MKPointAnnotation()
    
    func AddPin(_ uiGestureRecognizer: UIGestureRecognizer) {
        if ( uiGestureRecognizer.state == .began) {
            print("began")
            let touchPoint = uiGestureRecognizer.location(in: self.mapView)
            let pinCoord: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            
            mapPointAnnotation = MKPointAnnotation()
            mapPointAnnotation.coordinate = pinCoord
        }
        else if ( uiGestureRecognizer.state == .changed) {
            print("changed")
            let touchPoint = uiGestureRecognizer.location(in: self.mapView)
            let pinCoord: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            
            mapPointAnnotation.coordinate = pinCoord
            mapView.addAnnotation(mapPointAnnotation)
        }
        else if ( uiGestureRecognizer.state == .ended) {
            print("ended")
            do {
                let context = CoreDataStackManager.sharedInstance().managedObjectContext!
                _ = MapPin(lat: mapPointAnnotation.coordinate.latitude, long: mapPointAnnotation.coordinate.longitude, context: context)
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    
    //Fetch pin
    func fetchPins() {
        do {
            let storedMapPins = NSFetchRequest<MapPin>(entityName: "MapPin")
            let context = CoreDataStackManager.sharedInstance().managedObjectContext!
            let mapPins = try context.fetch(storedMapPins) as [Virtual_Tourist_v2.MapPin]
            
            for mapPin in mapPins {
                let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(mapPin.latitude), CLLocationDegrees(mapPin.longitude))
                let newAnnotation = MKPointAnnotation()
                newAnnotation.coordinate = coordinate
                mapView.addAnnotation(newAnnotation)
            }
        } catch let error {
            print (error)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let centerCoordinate = mapView.region.center
        
        let lat = centerCoordinate.latitude
        let long = centerCoordinate.longitude
        
        let latDelta = mapView.region.span.latitudeDelta
        let longDelta = mapView.region.span.longitudeDelta
        
        UserDefaults.standard.set(lat, forKey: "mapLat")
        UserDefaults.standard.set(long, forKey: "mapLong")
        
        UserDefaults.standard.set(latDelta, forKey: "mapLatDelta")
        UserDefaults.standard.set(longDelta, forKey: "mapLongDelta")
    }
}

