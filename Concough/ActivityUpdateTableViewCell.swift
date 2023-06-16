//
//  ActivityUpdateTableViewCell.swift
//  Concough
//
//  Created by Owner on 2018-03-25.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit

class ActivityUpdateTableViewCell: UITableViewCell {
    @IBOutlet weak var loading: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func cellConfigure() {
        self.loading.startAnimating()
    }

}
