//
//  EDHeaderSectionTableViewCell.swift
//  Concough
//
//  Created by Owner on 2016-12-20.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON

class EDHeaderSectionTableViewCell: UITableViewCell {

    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var headerSubTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
    internal func configureCell(title title: String, extraData: JSON?) {
        self.headerTitle.text = title
        
        if let data = extraData {
            var s = ""
            for (key, item) in data {
                s += "\(key): \(item.stringValue)" + " - "
            }
            
            if s.characters.count > 3 {
                s = s.substringToIndex(s.endIndex.advancedBy(-3))
            }
            self.headerSubTitle.text = s
        }
    }
}
