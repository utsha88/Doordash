//
//  RestaurantsListViewController.swift
//  Doordash
//
//  Created by Utsha Guha on 8/13/18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

import Foundation
import UIKit

class RestaurantsListViewController: UIViewController,UITableViewDataSource, UITabBarDelegate {
    
    @IBOutlet weak var favToolbarItem: UITabBarItem!
    @IBOutlet weak var exploreToolbarItem: UITabBarItem!
    @IBOutlet weak var restTableView: UITableView!
    var restaurantsList:[[String:Any]] = []
    //var imageArray:[UIImage] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(self.restaurantsList)
    }
    
    /********   Table View Datasource: Begin   ********/
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.restaurantsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:RestaurantCellView = tableView .dequeueReusableCell(withIdentifier: ConstantString.kCellId, for: indexPath) as! RestaurantCellView
        let selectedRestaurant:[String:Any] = self.restaurantsList[indexPath.row] 
        /********   Paint table view cell: Begin   ********/
        cell.restName.text = selectedRestaurant[ConstantString.kNameKey] as? String
        cell.restTime.text = "\(selectedRestaurant[ConstantString.kASAPTimeKey]!) min"
        cell.restType.text = selectedRestaurant[ConstantString.kDescriptionKey] as? String
        if selectedRestaurant[ConstantString.kDeliveryFeeKey]! as! Int == 0 {
            cell.restCost.text = ConstantString.kFreeDeliveryKey
        }
        else{
            cell.restCost.text = "$\(String(describing: selectedRestaurant[ConstantString.kDeliveryFeeKey] as? Int)) delivery"
        }
        cell.restPoster.image = selectedRestaurant[ConstantString.kImageKey] as! UIImage?//self.imageArray[indexPath.row]
        /********   Paint table view cell: End   ********/
        return cell
    }
    /********   Table View Datasource: End   ********/
    
    /********   Tab Bar Delegate: Begin   ********/
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 1 {
            // Explore
            _ = navigationController?.popViewController(animated: true)
        }
        else{
            // Favorites
        }
    }
    /********   Tab Bar Delegate: End   ********/

}
