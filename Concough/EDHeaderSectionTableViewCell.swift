//
//  EDHeaderSectionTableViewCell.swift
//  Concough
//
//  Created by Owner on 2016-12-20.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class EDHeaderSectionTableViewCell: UITableViewCell {

    @IBOutlet weak var headerTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
    internal func configureCell(title title: String) {
        self.headerTitle.text = title
    }
}
