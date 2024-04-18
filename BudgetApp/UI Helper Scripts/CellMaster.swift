//
//  CellMaster.swift
//  BudgetApp
//
//  Created by Dom Kinsler on 15/04/2024.
//

import UIKit

//Short class to help with a custom cell
class CellMaster: UITableViewCell {
    
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var spent: UILabel!
    @IBOutlet weak var icon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
