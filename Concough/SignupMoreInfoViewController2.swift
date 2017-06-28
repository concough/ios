//
//  SignupMoreInfoViewController2.swift
//  Concough
//
//  Created by Owner on 2016-12-11.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class SignupMoreInfoViewController2: UIViewController, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    internal var infoStruct:SignupMoreInfoStruct?
    internal var Years: [Int] = []
    internal var calendar: NSCalendar!
    
    @IBOutlet weak var datePickerYear: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //setting calendar of DatePicker
        self.calendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierPersian)
//        self.datePicker.timeZone = NSTimeZone(name: "Asia/tehran")
//        self.datePicker.locale = NSLocale(localeIdentifier: "fa_IR")
//        self.datePicker.calendar = calendar
        
        self.datePickerYear.dataSource = self
        self.datePickerYear.delegate = self
        
        let fifteenYearsToNow = self.calendar?.dateByAddingUnit(.Year, value: -10, toDate: NSDate(), options: [])
//            self.datePicker.maximumDate = fifteenYearsToNow
        let currentYear = self.calendar?.component(.Year, fromDate: fifteenYearsToNow!)
        for i in (currentYear!-81...currentYear!).reverse() {
            self.Years.append(i)
        }
//
//        } else {
////            self.datePicker.maximumDate = NSDate()
//        }
        
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
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.Years.count
    }

//    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return self.Years[row]
//    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var label = view as! UILabel!
        if label == nil {
            label = UILabel()
        }
        
        let data = self.Years[row]
        let attributes = NSDictionary(object: UIFont(name: "IRANYekanMobile-Bold", size: 16)! , forKey: NSFontAttributeName) as! [String: AnyObject]
        let title = NSAttributedString(string: FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(data)!, attributes: attributes)
        label.attributedText = title
        label.textAlignment = .Center
        return label
    }
    
    // MARK: - Functions
    @IBAction func nextButtonPressed(sender: UIBarButtonItem) {
        let selected = self.datePickerYear.selectedRowInComponent(0)
        
        let dateComponents = NSDateComponents()
        dateComponents.year = self.Years[selected]
        
        let userCalendar = self.calendar
        self.infoStruct!.birthday = userCalendar.dateFromComponents(dateComponents)
        
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
