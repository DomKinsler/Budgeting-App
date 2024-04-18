//
//  MonthsTableController.swift
//  BudgetApp
//
//  Created by Dom Kinsler on 17/04/2024.
//

import Foundation
import UIKit
import CoreData

class MonthsTableController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var allData: [NSManagedObject] = []
    var rows: Int = 0
    var year: String = ""
    var month: String = ""
    var datesArray: [String] = []
    var selectedDate: String = ""
    
    //Set rows for the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datesArray.count
    }
    
    //Populate table cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! CellMaster
        let currentDate = datesArray[indexPath.row]
        
        aCell.icon.image = UIImage(systemName: "circle.fill")!.withTintColor(.orange)
        aCell.category.text = currentDate
        aCell.spent.text = ""
        
        return aCell
    }
    
    //Start segue when clicking on a table cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDate = datesArray[indexPath.row]
        performSegue(withIdentifier: "toBreakdown", sender: nil)
    }
    
    //Prepare function to send year and month over the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBreakdown"{
            let monthOverviewController = segue.destination as! MonthOverviewController
            let selectedDateArr: [String] = selectedDate.components(separatedBy: "/")
            monthOverviewController.year = selectedDateArr[1]
            monthOverviewController.month = selectedDateArr[0]
        }
    }
    
    //Fetch all data from the past two years from core data
    func fetchData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"Categories")
        fetchRequest.predicate = NSPredicate(format: "year == %@ or year == %@", year, String(Int(year)! - 1))
        do {
            allData = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    //Format an array based on unique months/years within the last two years which is used for the table
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        year = dateFormatter.string(from: Date())
        dateFormatter.dateFormat = "MM"
        month = dateFormatter.string(from: Date())
        
        fetchData()
        
        let currentYear: [NSManagedObject] = allData.filter{ ($0.value(forKey: "year") as? String) == year }
        let lastYear: [NSManagedObject] = allData.filter{ ($0.value(forKey: "year") as? String) != year }
        
        var monthsLast: [String] = Array(Set(lastYear.map{ (($0.value(forKey: "month") as? String)!) }))
        var monthsThis: [String] = Array(Set(currentYear.map{ (($0.value(forKey: "month") as? String)!) }))
        
        monthsLast = monthsLast.map{ "\($0)/\(Int(year)! - 1)" }
        monthsThis = monthsThis.map{ "\($0)/\(year)" }
        
        monthsLast = monthsLast.sorted{ $0 > $1 }
        monthsThis = monthsThis.sorted{ $0 > $1 }
        
        datesArray = monthsThis + monthsLast
        

    }
    
}
    
