//
//  SignupMoreInfoViewController2.swift
//  Concough
//
//  Created by Owner on 2016-12-11.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class SignupMoreInfoViewController2: UIViewController, UINavigationControllerDelegate {
    internal var infoStruct:SignupMoreInfoStruct!

    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //setting calendar of DatePicker
        let calendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierPersian)
        self.datePicker.timeZone = NSTimeZone(name: "Asia/tehran")
        self.datePicker.locale = NSLocale(localeIdentifier: "fa_IR")
        self.datePicker.calendar = calendar
        
        if let fifteenYearsToNow = calendar?.dateByAddingUnit(.Year, value: -15, toDate: NSDate(), options: []) {
            self.datePicker.maximumDate = fifteenYearsToNow
        } else {
            self.datePicker.maximumDate = NSDate()
        }
        
        if self.navigationController != nil {
            self.title = "کنکوق"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "بعدی", style: .Plain, target: self, action: #selector(self.nextButtonPressed(_:)))            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Functions
    @IBAction func nextButtonPressed(sender: UIBarButtonItem) {
        self.infoStruct.birthday = datePicker.date
        
        performSegueWithIdentifier("SignupMoreInfoVC3Segue", sender: self)
    }
    
    // MARK: - Delegates
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? SignupMoreInfoViewController1 {
            controller.infoStruct = self.infoStruct
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SignupMoreInfoVC3Segue" {
            if let nextVC = segue.destinationViewController as? SignupMoreInfoViewController3 {
                nextVC.infoStruct = self.infoStruct
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "تاریخ تولد", style: .Plain, target: self, action: nil)
                
            }
        }
    }
}
