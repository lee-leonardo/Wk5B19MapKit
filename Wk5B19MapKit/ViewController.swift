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
import CoreBluetooth

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, CBPeripheralManagerDelegate, UIGestureRecognizerDelegate {
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var latitudeTextField: UITextField!
	@IBOutlet weak var longitudeTextField: UITextField!
	
	//CoreData
	var reminderContext : NSManagedObjectContext!
	var locationManager = CLLocationManager()
	var peripheralManager : CBPeripheralManager!
	
	var locationPins : MKPinAnnotationView!
	var reminders = [MKAnnotation]()

	//Bluetooth
	let elevatorUUID = NSUUID(UUIDString: "DF460DF8-B6DF-4F6C-BF13-CB46D98B8578")
	let deviceIdentifier = "com.codefellows.beacons.elevator"
	var elevatorBeacon : CLBeaconRegion!
	var elevatorBeaconData : NSMutableDictionary!

//MARK: - View methods
	override func viewDidLoad() {
		super.viewDidLoad()
		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.delegate = self
		self.mapView.delegate = self
		
		//Context setup
		var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
		self.reminderContext = appDelegate.managedObjectContext
		
		//CoreBluetooth
		self.elevatorBeacon = CLBeaconRegion(proximityUUID: self.elevatorUUID, identifier: self.deviceIdentifier)
		self.elevatorBeaconData = self.elevatorBeacon.peripheralDataWithMeasuredPower(nil)
		self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
		
		//To execute a fetchRequest.
		//var fetch = NSFetchRequest(entityName: "Reminder")
		//var reminders = self.reminderContext.executeFetchRequest(fetch, error: nil)
		
		//LongGesture
		var longPress = UILongPressGestureRecognizer(target: self, action: "mapPressed:")
		self.mapView.addGestureRecognizer(longPress)

	}
	override func viewDidAppear(animated: Bool) {
		self.locationManager.startUpdatingLocation()
		self.locationManager.startMonitoringSignificantLocationChanges()
		self.locationManager.startRangingBeaconsInRegion(self.elevatorBeacon)
		
		if self.reminderContext != nil {
			checkRemindersForMapView()
		}

	}
	override func viewWillDisappear(animated: Bool) {
		self.locationManager.stopUpdatingLocation()
		self.locationManager.stopMonitoringSignificantLocationChanges()
		self.locationManager.stopMonitoringForRegion(self.elevatorBeacon)

	}
	
//MARK: RemindersTableView
	@IBAction func showReminders(sender: AnyObject) {
		self.performSegueWithIdentifier("ShowReminders", sender: self)
	}
//MARK: - Segue
	override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
		if segue.identifier == "ShowReminders" {
			let destination = segue.destinationViewController as RemindersViewController
			destination.reminderContext = self.reminderContext
		}
	}
	
//MARK: - CoreData
	func addReminder(coordinate : CLLocationCoordinate2D) {
		var reminder = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext: self.reminderContext) as Reminder
		reminder.latitude = coordinate.latitude
		reminder.longitude = coordinate.longitude
		reminder.message = "No message yet"
		
		println(reminder)
		
		var error : NSError?
		self.reminderContext.save(&error)
		if error != nil {
			println(error?.localizedDescription)
		}
		
		//println(reminder.message)
	}

	func checkRemindersForMapView() {
		var fetch = NSFetchRequest(entityName: "Reminder")
		var reminders = self.reminderContext.executeFetchRequest(fetch, error: nil)
		var reminderList = [MKAnnotation]()
		
		for reminder in reminders {
			if let theReminder = reminder as? Reminder {
				var coordinate = CLLocationCoordinate2D(latitude: theReminder.latitude, longitude: theReminder.longitude)
				var annotation = MKPointAnnotation()
				annotation.coordinate = coordinate
				annotation.title = theReminder.message
				
				reminderList.append(annotation)
			}
		}
		
		self.reminders = reminderList
		self.mapView.addAnnotations(reminders)
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
			println("Not began state")
		}
	}
	func pinLocation(annotation: MKPointAnnotation) {
		annotation.title = "Reminder Title"
		self.addReminder(annotation.coordinate)
		self.mapView.addAnnotation(annotation)
	}
//MARK: - Delegates
	//MARK: CBPeripheralManagerDelegate
	func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
		var state = peripheral.state
		switch state {
		case .PoweredOn:
			self.peripheralManager.startAdvertising(elevatorBeaconData)
		case .PoweredOff:
			self.peripheralManager.stopAdvertising()
		default:
			println("Um")
		}
	}
	
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
		
		if region == self.elevatorBeacon {
			var notification = UILocalNotification()
			notification.alertBody = "Near the region!"
			notification.alertAction = "What would I put here?"
		}
		
		//Put a local notification here.
		//var notification = UILocalNotification()
		//notification.alertBody = "Entered a region!"
		//notification.alertAction = ""
		
	}
	func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
		println("Did leave")
		//I would copy the didEnterRegion logic to implement.
	}
	
//MARK: MKMapViewDelegate
	func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
		//refactor into a subroutine.
		if let selectedAnnotation = annotation as? MKUserLocation {
			return nil
		}
		
		if !self.locationPins {
			self.locationPins = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
			self.locationPins.pinColor = MKPinAnnotationColor.Red
			self.locationPins.animatesDrop = true
			self.locationPins.canShowCallout = true
		} else {
			self.locationPins.annotation = annotation
			return self.locationPins
		}
		
		return nil
	}
	
	//For the accessories on the pins.
	//func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
	//		var annotation = view.annotation
	//		annotation.coordinate
	//}
}
