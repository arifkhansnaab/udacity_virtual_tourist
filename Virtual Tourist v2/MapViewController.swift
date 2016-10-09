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
    }

 
    /******************************************
    **HELP NEEDED: After adding below 2 func, no pin was getting visiable on the map. Unable to figure out why.
    */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var v : MKAnnotationView! = nil
        let ident = "pin"
        v = mapView.dequeueReusableAnnotationView(withIdentifier: ident)
        if v == nil {
            v = MKAnnotationView(annotation:annotation, reuseIdentifier:ident)
        }
        
        v.annotation = annotation
        v.isDraggable = true
        return v
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending, .canceling:
            view.dragState = .none
        default: break
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
    
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
            return;
        }
        
        //If user is not in the deletion mode, then open the map and images
        let mapPin = MapPin(lat: latitutde!, long: longitude!, context: context)
        
        let oViewController = self.storyboard!.instantiateViewController(withIdentifier: "MapPhotoCollectionViewController") as! MapPhotoCollectionViewController
        oViewController.mapPin = mapPin
        oViewController.mapView = mapView
        self.navigationController!.pushViewController(oViewController, animated: true)
    }
    
    //Add pin on the map when user holds the long press
    func AddPin(_ uiGestureRecognizer: UIGestureRecognizer) {
        if ( uiGestureRecognizer.state == .began) {
            let touchPoint = uiGestureRecognizer.location(in: self.mapView)
            let pinCoord: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            
            let mapPointAnnotation = MKPointAnnotation()
            mapPointAnnotation.coordinate = pinCoord
            mapView.addAnnotation(mapPointAnnotation)
            
            do {
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                _ = MapPin(lat: pinCoord.latitude, long: pinCoord.longitude, context: context)
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
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let mapPins = try context.fetch(storedMapPins) as [Virtual_Tourist_v2.MapPin]
            
            for mapPin in mapPins {
                let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(mapPin.latitude!), CLLocationDegrees(mapPin.longitude!))
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
