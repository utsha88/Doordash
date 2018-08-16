//
//  ViewControllerExtension.swift
//  Doordash
//
//  Created by Utsha Guha on 8/14/18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension UIViewController{
    func showAlert(heading:String, message:String, buttonTitle:String) {
        let alert = UIAlertController(title: heading, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

