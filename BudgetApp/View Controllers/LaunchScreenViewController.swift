//
//  LaunchScreenViewController.swift
//  BudgetApp
//
//  Created by Dom Kinsler on 18/04/2024.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    @IBOutlet weak var logoImage: UIImageView!
    
    
    //Short animation for logo on app startup
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        let popDuration = 0.4
        let scaleFactor = 1.1
        
        let initialFrame = logoImage.frame
        let imageWidth = initialFrame.width
        
        let newSize = imageWidth * scaleFactor
        let diffWidths = newSize  - imageWidth
        
        let newX = initialFrame.origin.x - diffWidths/2
        let newY = initialFrame.origin.y - diffWidths/2
        
        UIView.animate(withDuration: popDuration, animations: {
            self.logoImage.frame = CGRect(x: newX, y: newY, width: newSize, height: newSize)
        })
        
        UIView.animate(withDuration: popDuration, delay: popDuration, animations: {
            self.logoImage.frame = initialFrame
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (2 * popDuration) + 0.7, execute: {
            self.performSegue(withIdentifier: "toApp", sender: nil)
        })
    }

}

