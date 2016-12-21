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
    }

    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
    internal func configureCell(title title: String, imageName: String, showButtonView: Bool = true) {
        //self.titleLable.text = title
        //self.iconImageView.image = UIImage(named: imageName)
        //self.buttonLineView.hidden = !showButtonView
    }

    internal func configureCell(data data: [(title: String, image: String)]) {
        let booklet = data[1]
        let time = data[2]
        let year = data[0]
        
        self.bookletImageView.image = UIImage(named: booklet.image)
        self.bookletLable.text = booklet.title
        
        self.timeImageView.image = UIImage(named: time.image)
        self.timeLable.text = time.title
        
        self.yearImageView.image = UIImage(named: year.image)
        self.yearLable.text = year.title
    }
}
