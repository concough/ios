//
//  EntranceLessonExamDialogViewController.swift
//  Concough
//
//  Created by Owner on 2018-04-08.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit

class EntranceLessonExamDialogViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var startExamButton: UIButton!
    @IBOutlet weak var cancelExamButton: UIButton!
    
    internal var examDelegate: EntranceLessonExamDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.messageLabel.text = "سنجش بدون زمانبندی است. در هر زمان می توانید نسبت به پایان سنجش اقدام نمایید.\n\nعوض شدن رنگ تایمر به منظور اطلاع رسانی است.\n\nدر صورتی که از سنجش پشیمان گشتید بدون جواب به هیچ سوالی پایان سنجش را بزنید."
        
        self.startExamButton.layer.cornerRadius = 10.0
        self.startExamButton.layer.masksToBounds = true

        self.cancelExamButton.layer.cornerRadius = 10.0
        self.cancelExamButton.layer.masksToBounds = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startExamPressed(sender: UIButton) {
        if let delegate = self.examDelegate {
            delegate.startLessonExam()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelExamPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
