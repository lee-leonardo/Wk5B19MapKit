//
//  RemindersViewController.swift
//  Wk5B19MapKit
//
//  Created by Leonardo Lee on 8/21/14.
//  Copyright (c) 2014 Leonardo Lee. All rights reserved.
//

import UIKit
import CoreData

class RemindersViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var reminderTableView: UITableView!
	
	var reminderContext : NSManagedObjectContext!
	var reminderFetchResults : NSFetchedResultsController!
	var sortKey : String!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//Setup CoreData
		self.setupCoreData()

		println(self.reminderFetchResults.sections)
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		var error : NSError?
		self.reminderFetchResults.performFetch(&error)
		if error != nil {
			println(error)
		}
		
	}
//MARK: Core Data
	func setupCoreData() {
		self.sortKey = "message"
		requestReminders()
		
	}
	func requestReminders() {
		var request = NSFetchRequest(entityName: "Reminder")
		var sort = NSSortDescriptor(key: self.sortKey, ascending: true)
		request.sortDescriptors = [sort]
		//request.fetchBatchSize = 20
		
		self.reminderFetchResults = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.reminderContext, sectionNameKeyPath: nil, cacheName: nil)
		self.reminderFetchResults.delegate = self //This belongs here because the tableView will manage the reminders, not the mapViewController (which will make them).
	}
	
	@IBAction func resortReminders(sender: AnyObject) {
		println("Resort enacted!")
		
		var resortActionSheet = UIAlertController(title: "Sort By", message: "This helps you organize your reminders", preferredStyle: UIAlertControllerStyle.ActionSheet)
		prepareResortController(resortActionSheet)
		
		if resortActionSheet.popoverPresentationController != nil {
			resortActionSheet.popoverPresentationController.barButtonItem = sender as UIBarButtonItem
		}
		
		self.presentViewController(resortActionSheet, animated: true) {
			() -> Void in
			self.requestReminders()
			self.reminderFetchResults.performFetch(nil) //Would this be performant?
			self.reminderTableView.reloadData()
		}
	}
	func prepareResortController(actionSheet: UIAlertController) {
		let selectAlphabetical = UIAlertAction(title: "Normal", style: UIAlertActionStyle.Default) {
			(action) -> Void in
			self.sortKey = "message"
		}
		
		let selectLatitude = UIAlertAction(title: "Latitude", style: UIAlertActionStyle.Default) {
			(action) -> Void in
			self.sortKey = "latitude"
		}
		
		let selectLongitude = UIAlertAction(title: "Longitude", style: UIAlertActionStyle.Default) {
			(action) -> Void in
			self.sortKey = "longitude"
		}
		
		let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
		
		actionSheet.addAction(selectAlphabetical)
		actionSheet.addAction(selectLatitude)
		actionSheet.addAction(selectLongitude)
		actionSheet.addAction(cancel)
	}
	
//MARK: - Delegates
//MARK: NSFetchedResults
	func controllerWillChangeContent(controller: NSFetchedResultsController!) {
		self.reminderTableView.beginUpdates()
	}
	func controllerDidChangeContent(controller: NSFetchedResultsController!) {
		self.reminderTableView.endUpdates()
	}
	func controller(controller: NSFetchedResultsController!, didChangeObject anObject: AnyObject!, atIndexPath indexPath: NSIndexPath!, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath!) {
		switch type {
		case .Insert:
			self.reminderTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
		case .Update:
			self.prepareTableViewCell(self.reminderTableView.cellForRowAtIndexPath(indexPath), forIndexPath: indexPath)
		case .Move:
			self.reminderTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
			self.reminderTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
		case .Delete:
			self.reminderTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		}
	}
//MARK: TableViewDelegate
	func tableView(tableView: UITableView!, editActionsForRowAtIndexPath indexPath: NSIndexPath!) -> [AnyObject]! {
		
		let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") { (action, indexPath) -> Void in
			if let reminder = self.reminderFetchResults.fetchedObjects[indexPath.row] as? Reminder {
				self.reminderContext.deleteObject(reminder)
				self.reminderContext.save(nil) //Could implement error here.
			}
		}
		deleteAction.backgroundColor = UIColor.redColor()

		let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit") { (action, indexPath) -> Void in
			println("Edit button tapped.")
			
			var editAlert = UIAlertController(title: "Edit", message: "Edit here:", preferredStyle: UIAlertControllerStyle.Alert)
			self.prepareEditAlertController(editAlert, indexPath: indexPath)
			self.presentViewController(editAlert, animated: true, completion: nil)
			
		}
		editAction.backgroundColor = UIColor.lightGrayColor()
		
		return [deleteAction, editAction]
	}
	func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
		//Nothing needed
	}

	func prepareEditAlertController(controller: UIAlertController, indexPath: NSIndexPath) {
		controller.addTextFieldWithConfigurationHandler({
			(textField: UITextField!) -> Void in
			if let reminder = self.reminderFetchResults.fetchedObjects[indexPath.row] as? Reminder {
				textField.text = reminder.message
				
			}
		})
		
		let done = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: {
			(action) -> Void in
			if let reminder = self.reminderFetchResults.fetchedObjects[indexPath.row] as? Reminder {
				if let textField = controller.textFields.first as? UITextField {
					reminder.message = textField.text
				}
				
				var error : NSError?
				self.reminderContext.save(&error)
				if error != nil {
					println(error)
				}
			}
			self.dismissViewControllerAnimated(true, completion: nil)
		})
		
		let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
		
		controller.addAction(done)
		controller.addAction(cancel)
	}
//MARK: TableViewDataSource
	func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
		if reminderFetchResults != nil {
			return self.reminderFetchResults!.sections[section].numberOfObjects
		}
		return 10
	}
	func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
		var cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell", forIndexPath: indexPath) as UITableViewCell
		prepareTableViewCell(cell, forIndexPath: indexPath)
		
		return cell
	}
	func prepareTableViewCell(cell: UITableViewCell, forIndexPath: NSIndexPath) {
		var reminder = self.reminderFetchResults.fetchedObjects[forIndexPath.row] as Reminder
		cell.textLabel.text = reminder.message
	}
}
