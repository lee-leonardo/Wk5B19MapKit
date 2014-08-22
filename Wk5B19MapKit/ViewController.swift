//
//  ViewController.swift
//  Wk5B19MapKit
//
//  Created by Leonardo Lee on 8/21/14.
//  Copyright (c) 2014 Leonardo Lee. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var latitudeTextField: UITextField!
	@IBOutlet weak var longitudeTextField: UITextField!
	
	//CoreData
	var locationManager = CLLocationManager()
	var reminderContext : NSManagedObjectContext!
	var reminderFetchResults : NSFetchedResultsController!
	var reminders = [Reminder]()
	
	
//MARK: - View methods
	override func viewDidLoad() {
		super.viewDidLoad()
		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.delegate = self
		self.mapView.delegate = self
		
		//Setup CoreData
		var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
		self.reminderContext = appDelegate.managedObjectContext
		self.setupCoreData()
		
		//LongGesture
		var longPress = UILongPressGestureRecognizer(target: self, action: "mapPressed:")
		self.mapView.addGestureRecognizer(longPress)
	}
	override func viewDidAppear(animated: Bool) {
		self.locationManager.startUpdatingLocation()
		self.locationManager.stopMonitoringSignificantLocationChanges()
	}
	override func viewWillDisappear(animated: Bool) {
		self.locationManager.stopUpdatingLocation()
	}
	
//MARK: RemindersTableView
	@IBAction func showReminders(sender: AnyObject) {
		self.performSegueWithIdentifier("ShowReminders", sender: self)
	}
//MARK: - Segue
	override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
		if segue.identifier == "ShowReminders" {
			let destination = segue.destinationViewController as RemindersViewController
			destination.reminderFetchResults = self.reminderFetchResults
		}
	}
	
//MARK: - CoreData
	func setupCoreData() {
		var request = NSFetchRequest(entityName: "Reminder")
		var sort = NSSortDescriptor(key: "message", ascending: true)
		request.sortDescriptors = [sort]
		//request.fetchBatchSize = 20
		
		
	}
	func addReminder(coordinate : CLLocationCoordinate2D) {
		var reminder = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext: self.reminderContext) as Reminder
		reminder.latitude = coordinate.latitude
		reminder.longitude = coordinate.longitude
		reminder.message = "No message yet"
		
		var error : NSError?
		self.reminderContext.save(&error)
		if error != nil {
			println(error?.localizedDescription)
		}
		println(reminder)
	}

//MARK: - Pin Methods
	@IBAction func placePin(sender: AnyObject) {
		var latitude = self.latitudeTextField.text as NSString
		var longitude = self.longitudeTextField.text as NSString
		
		var setCoordinate = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
		var pin = MKPointAnnotation()
		pin.coordinate = setCoordinate
		pinLocation(pin)
	}
	func mapPressed(sender: UIGestureRecognizer) {
		var state = sender.state
		switch state {
		case .Began:
			//println("Began")
			var touchPoint = sender.locationInView(self.mapView)
			var touchCoordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
			
			var pin = MKPointAnnotation()
			pin.coordinate = touchCoordinate
			pinLocation(pin)
			
		default:
			println("Anything else")
		}
	}
	func pinLocation(annotation: MKPointAnnotation) {
		annotation.title = "Reminder Title"
		self.addReminder(annotation.coordinate)
		self.mapView.addAnnotation(annotation)
	}
//MARK: - Delegates
//MARK: NSFetchedResultsControllerDelegate
	
//MARK: CLLocationManagerDelegate
	func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		switch status {
		case .Authorized, .AuthorizedWhenInUse:
			println("No problem")
			self.mapView.showsUserLocation = true
			if CLLocationManager.significantLocationChangeMonitoringAvailable() {
				locationManager.startMonitoringSignificantLocationChanges()
			}
		case .Denied, .Restricted:
			println("Cannot do anything with these settings.")
		case .NotDetermined:
			println("Undetermined status.")
			self.locationManager.requestWhenInUseAuthorization()
		}
	}
	func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
		println("Did enter")
		
		//Put a local notification here.
		//var notification = UILocalNotification()
		//notification.alertBody = "Entered a region!"
		//notification.alertAction = ""
		
	}
	func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
		println("Did leave")
	}
	
//MARK: MKMapViewDelegate
	func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
		var annotation = view.annotation
		annotation.coordinate
		
		
		
	}
//	func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
	//refactor into a subroutine.
	//		var annotationView = MKAnnotationView()
	//		if let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("Pin") as? MKPinAnnotationView {
	//
	//		} else {
	//
	//		}
	//
	//		if annotationView == nil {
	//			annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin") //ReuseID set here not on SB
	//
	//		}
	//		annotationView.animatesDrop = true
	//		annotationView.canShowCallout = true
	
	//		var rButton = UIButton.buttonWithType(UIButtonType.ContactAdd) as UIButton
	//		annotationView.rightCalloutAccessoryView = rButton
	
	//		return annotationView
//	}

}

