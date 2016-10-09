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


class MapPhotoCollectionViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var URLs = [String]()
    var mapPin: MapPin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        FlickrApi.sharedInstance.getPhotos(Double(mapPin.latitude!), longitude: Double(mapPin.longitude!)) { (result, error) in
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.URLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //delete photo
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        let url = URL(string: self.URLs[(indexPath as NSIndexPath).item])
        let data = NSData(contentsOf: url!)
        let image = UIImage(data: data! as Data)
        cell.imageView.image = image
        return cell
    }
    
    func setMapRegion() {
        let latitude:CLLocationDegrees = mapPin.latitude as! CLLocationDegrees
        let longitude:CLLocationDegrees = mapPin.longitude as! CLLocationDegrees
        let latDelta:CLLocationDegrees = 1.99
        let lonDelta:CLLocationDegrees = 1.99
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: false)
        
    }
   }
