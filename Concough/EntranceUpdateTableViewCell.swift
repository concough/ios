//
//  EntranceUpdateTableViewCell.swift
//  Concough
//
//  Created by Owner on 2016-11-10.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class EntranceUpdateTableViewCell: UITableViewCell {

    @IBOutlet weak var containerUIView: UIView!
    @IBOutlet weak var entranceTitleUILabel: UILabel!
    @IBOutlet weak var entranceSetUILabel: UILabel!
    @IBOutlet weak var entranceUpdateTimeUILabel: UILabel!
    @IBOutlet weak var entranceImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
