//
//  MonthOverview.swift
//  BudgetApp
//
//  Created by Dom Kinsler on 17/04/2024.
//

import Foundation
import UIKit
import CoreData

class MonthOverviewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var totalSpent: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var thisMonth: [NSManagedObject] = []
    var year: String = ""
    var month: String = ""
    
    //Set number of rows in the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thisMonth.count
    }
    
    //Populate table cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! CellMaster
        let currentCategory = thisMonth[indexPath.row]
        
        aCell.icon.image = UIImage(systemName: currentCategory.value(forKey: "icon") as? String ?? "paperplane.fill")?.withTintColor(currentCategory.value(forKey: "colour") as? UIColor ?? UIColor(ciColor: .red), renderingMode: .alwaysOriginal)
        aCell.category.text = currentCategory.value(forKey: "category") as? String
        aCell.spent.text = "Spent: £\(String(format: "%.2f", currentCategory.value(forKey: "spent") as? Double ?? 0))"
        
        return aCell
    }
    
    //Pulls data in from core data based
    func fetchData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"Categories")
        fetchRequest.predicate = NSPredicate(format: "year = %@ and month = %@", year, month)
        do {
            thisMonth = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    //Updates the label holding total spent in the month
    func updateTotal(){
        var total: Double = 0
        
        thisMonth.forEach{
            total += $0.value(forKey: "spent") as! Double
        }
        
        totalSpent.text = "Total Spent: £\(String(format: "%.2f", total))"
    }
    
    //Setup initial view
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        viewTitle.text = "\(month)/\(year) Breakdown"
        
        fetchData()
        updateTotal()

    }
    
    //Action to go back a page
    @IBAction func closeOverviewPush(_ sender: Any) {
        
        dismiss(animated: true)
        
    }
    
}



