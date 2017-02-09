//
//  EDInformationSectionTableViewCell.swift
//  Concough
//
//  Created by Owner on 2016-12-20.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class EDInformationSectionTableViewCell: UITableViewCell {

    @IBOutlet weak var bookletImageView: UIImageView!
    @IBOutlet weak var timeImageView: UIImageView!
    @IBOutlet weak var yearImageView: UIImageView!
    
    @IBOutlet weak var bookletLable: UILabel!
    @IBOutlet weak var timeLable: UILabel!
    @IBOutlet weak var yearLable: UILabel!

    @IBOutlet weak var buttonLineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
    internal func configureCell(title title: String, imageName: String, showButtonView: Bool = true) {
        //self.titleLable.text = title
        //self.iconImageView.image = UIImage(named: imageName)
        //self.buttonLineView.hidden = !showButtonView
    }

    internal func configureCell(bookletCount booklet: Int, duration: Int, year: Int) {
        self.bookletLable.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(booklet)! + " دفترچه"
        self.timeLable.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(duration)! + " دقیقه"
        self.yearLable.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(year)!
    }
}
