//
//  EntranceCreateTableViewCell.swift
//  Concough
//
//  Created by Owner on 2016-11-10.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class EntranceCreateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerUIView: UIView!
    @IBOutlet weak var entranceImage: UIImageView!
    @IBOutlet weak var entranceSetUILabel: UILabel!
    @IBOutlet weak var entranceTitleUILabel: UILabel!
    @IBOutlet weak var entranceYearUILabel: UILabel!
    @IBOutlet weak var entranceUpdateTimeUILabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
