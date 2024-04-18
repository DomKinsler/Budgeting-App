//
//  ViewController.swift
//  BudgetApp
//
//  Created by Dom Kinsler on 15/02/2024.
//

import UIKit
import CoreData

class MonthlyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var totalSpent: UILabel!
    
    @IBOutlet weak var newCategoryPopup: UIView!
    @IBOutlet weak var categoryColour: UIColorWell!
    @IBOutlet weak var categoryName: UITextField!
    
    @IBOutlet weak var newTransactionPopup: UIView!
    @IBOutlet weak var transactionAmount: UITextField!
    
    
    
    @IBOutlet weak var categoryPickerField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
 
    
    
    var thisMonth: [NSManagedObject] = []
    var year: String = ""
    var month: String = ""
    
    
    //Set number of rows in table
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
    
    //Delete element from table and core data with any money it contained going into other
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let toDelete = thisMonth[indexPath.row]
        
        let toAlocate = toDelete.value(forKey: "spent") as? Double ?? 0
        
        managedContext.delete(toDelete)
        
        do {
            try managedContext.save()
            // Remove the object from the array
            thisMonth.remove(at: indexPath.row)
            // Remove the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if (thisMonth.filter{ $0.value(forKey: "category") as? String == "Other"}.isEmpty){
                save(category: "Other", icon: "circle.fill", colour: UIColor(.purple))
            }
            
            update(category: "Other", spent: toAlocate)
            fetchData(fetchYear: year, fetchMonth: month)
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
        
    }
    
    //Components in pickerview
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Elements in pickerview
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return thisMonth.count
    }
    
    //Populate pickerview
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return thisMonth[row].value(forKey: "category") as? String

    }

    //Select item in pickerview
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        categoryPickerField.text = thisMonth[row].value(forKey: "category") as? String
        categoryPicker.isHidden = true

    }

    //Pickerview activation from a text field
    func textFieldDidBeginEditing(_ textField: UITextField) {

        if textField == categoryPickerField {
            categoryPicker.isHidden = false

            textField.endEditing(true)
            
        }

    }
    
    //Pulls data in from core data based on year and month
    func fetchData(fetchYear: String, fetchMonth: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"Categories")
        fetchRequest.predicate = NSPredicate(format: "year == %@ and month == %@", fetchYear, fetchMonth)
        do {
            thisMonth = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    //Creates a new category
    func save(category: String, icon: String, colour: UIColor/*, spent: Double*/) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let myNewCat = NSEntityDescription.insertNewObject(forEntityName: "Categories", into: managedContext)
        myNewCat.setValue(category, forKeyPath: "category")
        myNewCat.setValue(icon, forKeyPath: "icon")
        myNewCat.setValue(0, forKeyPath: "spent")
        myNewCat.setValue(colour, forKeyPath: "colour")
        myNewCat.setValue(year, forKeyPath: "year")
        myNewCat.setValue(month, forKeyPath: "month")
        do {
            try managedContext.save()
            //print("SAVED")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //Updates the amount spent in a category
    func update(category: String, spent: Double){
        var toUpdate: [NSManagedObject] = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
        fetchRequest.predicate = NSPredicate(format: "category == %@ and year == %@ and month == %@", category, year, month)
        
        do {
            toUpdate = try managedContext.fetch(fetchRequest) as? [NSManagedObject] ?? []
            if toUpdate.count != 0{
                let managedObject = toUpdate[0]
                managedObject.setValue((managedObject.value(forKey: "spent") as? Double)! + spent, forKey: "spent")
                
                try managedContext.save()
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        updateTotal()
    }
    
    //Updates the label holding total spent in the month
    func updateTotal(){
        var total: Double = 0
        
        thisMonth.forEach{
            total += $0.value(forKey: "spent") as! Double
        }
        
        totalSpent.text = "Total Spent: £\(String(format: "%.2f", total))"
    }

    //Sets up current year and month and populates table with basic categories when necessary
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        year = dateFormatter.string(from: Date())
        dateFormatter.dateFormat = "MM"
        month = dateFormatter.string(from: Date())
        
        fetchData(fetchYear: year, fetchMonth: month)
        
        //update(category: "Groceries", spent: 12)
        
        if (thisMonth.count == 0) {
            if (month == "01"){
                fetchData(fetchYear: String(Int(year)! - 1), fetchMonth: "12")
            }
            else{
                fetchData(fetchYear: year, fetchMonth: String(format: "%02d", Int(month)! - 1))
            }
            
            if (thisMonth.count == 1 || thisMonth.count == 0){
                save(category: "Groceries", icon: "circle.fill", colour: UIColor(.green)/*, spent: 32.60*/)
                save(category: "Nights Out", icon: "circle.fill", colour: UIColor(.black)/*, spent: 32.60*/)
                save(category: "Activities", icon: "circle.fill", colour: UIColor(.red)/*, spent: 32.60*/)
                save(category: "Other", icon: "circle.fill", colour: UIColor(.purple)/*, spent: 32.60*/)
                }
            else{
                thisMonth.forEach{ save(category: ($0.value(forKey: "category") as? String)!, icon: ($0.value(forKey: "icon") as? String)!, colour: ($0.value(forKey: "colour") as? UIColor)!) }
            }
            fetchData(fetchYear: year, fetchMonth: month)
        }
        updateTotal()
    }
    
    //Touching off a keyboard will close it
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    //Action for clicking the new category button showing a popup
    @IBAction func newCategory(_ sender: Any) {
        
        categoryName.text = ""
        
        newTransactionPopup.isHidden = true
        newCategoryPopup.alpha = 0
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations:{
            self.newCategoryPopup.isHidden = false
            self.newCategoryPopup.alpha = 1
        }, completion: nil)
        
    }
    
    //Action for closing new category popup
    @IBAction func closeNewCategory(_ sender: Any) {
        
        newCategoryPopup.isHidden = true
        
    }
    
    //Action for attempting to save a new category if it has a unique name
    @IBAction func submitNewCategory(_ sender: Any) {
        
        if !(categoryName.text == nil){
            if !(thisMonth.map{ ($0.value(forKey: "category") as? String)?.trimmingCharacters(in: CharacterSet.whitespaces).uppercased() }.contains(categoryName.text?.trimmingCharacters(in: CharacterSet.whitespaces).uppercased())){
                //print(categoryColour.selectedColor?. as? String ?? "NA")
                save(category: categoryName.text!.trimmingCharacters(in: CharacterSet.whitespaces), icon: "circle.fill", colour: categoryColour.selectedColor ?? UIColor(ciColor: .gray)/*, spent: 0*/)
                fetchData(fetchYear: year, fetchMonth: month)
                tableView.reloadData()
                newCategoryPopup.isHidden = true
            }
            else{
                print("Category already exists")
            }
            
        }
        else{
            print("Please enter a category name")
        }
        
    }
    
    //Action for clicking the new transaction button showing a popup
    @IBAction func newTransaction(_ sender: Any) {
        
        transactionAmount.text = ""
        categoryPickerField.text = ""
        categoryPicker.reloadAllComponents()
        
        newCategoryPopup.isHidden = true
        newTransactionPopup.alpha = 0
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations:{
            self.newTransactionPopup.isHidden = false
            self.newTransactionPopup.alpha = 1
        }, completion: nil)
        
    }
    
    //Actin for closing the new transaction popup
    @IBAction func closeNewTransaction(_ sender: Any) {
        
        newTransactionPopup.isHidden = true
        categoryPicker.isHidden = true
        
    }
    
    //Action for trying to save a new transaction by calling update
    @IBAction func submitNewTransaction(_ sender: Any) {
        
        update(category: categoryPickerField.text!, spent: Double(transactionAmount.text!) ?? 0)
        
        tableView.reloadData()
        
        newTransactionPopup.isHidden = true
        categoryPicker.isHidden = true
        
    }
    

}

