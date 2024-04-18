//
//  PopupView.swift
//  BudgetApp
//
//  Created by Dom Kinsler on 17/04/2024.
//

import UIKit

//Short class for formatting the popup views
class PopupView: UIView {

    let cornerRadius = 20
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = CGFloat(cornerRadius)
    }

}
