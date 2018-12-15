//
//  EntranceQuestionCommentTableViewCell.swift
//  Concough
//
//  Created by Owner on 2018-04-06.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON

class EntranceQuestionTextCommentTableViewCell: UITableViewCell {
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commmentDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .None
    }
    
    override func drawRect(rect: CGRect) {
//        self.commentImageView.tintImageColor(UIColor.darkGrayColor())
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    internal func configureCell(questionId: String, comment: EntranceQuestionCommentModel) {
        let data = JSON.parse(comment.commentData)
        if let text = data["text"].string {
            self.commentLabel.text = text
        }
        
        self.commmentDateLabel.text = comment.created.timeAgoSinceDate(lang: "fa", numericDates: true)
    }

}
