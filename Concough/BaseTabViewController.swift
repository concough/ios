//
//  BaseTabViewController.swift
//  Concough
//
//  Created by Owner on 2018-03-25.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit

class BaseTabViewController: UITabBarController, UITabBarControllerDelegate {

    private var previousIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if self.selectedIndex == self.previousIndex {
            if let navVc = viewController as? UINavigationController {
                if let topVc = navVc.viewControllers.first as? UITableViewController {
                    topVc.tableView.setContentOffset(CGPointZero, animated: true)
                }
            }
        }
        self.previousIndex = self.selectedIndex
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
