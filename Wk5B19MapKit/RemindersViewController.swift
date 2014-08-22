//
//  RemindersViewController.swift
//  Wk5B19MapKit
//
//  Created by Leonardo Lee on 8/21/14.
//  Copyright (c) 2014 Leonardo Lee. All rights reserved.
//

import UIKit
import CoreData

class RemindersViewController: UIViewController, UITableViewDataSource {

	@IBOutlet weak var reminderTableView: UITableView!
	var reminderFetchResults : NSFetchedResultsController!
	
    override func viewDidLoad() {
        super.viewDidLoad()

    }
	
//MARK: - TableView
	func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
		return 10
	}
	func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
		var cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell", forIndexPath: indexPath) as UITableViewCell
		prepareTableViewCell(cell, forIndexPath: indexPath)
		
		return cell
	}
	func prepareTableViewCell(cell: UITableViewCell, forIndexPath: NSIndexPath) {
		
	}
}
