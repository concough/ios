//
//  EntranceShowQuestionPreviewTableViewCell.swift
//  Concough
//
//  Created by Owner on 2018-04-12.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit
import RNCryptor

class EntranceShowQuestionPreviewTableViewCell: UITableViewCell {

    @IBOutlet weak var questionImageView1: UIImageView!
    @IBOutlet weak var questionImageView2: UIImageView!
    @IBOutlet weak var questionImageView3: UIImageView!
    @IBOutlet weak var questionImageConstraint2: NSLayoutConstraint?
    @IBOutlet weak var questionImageConstraint3: NSLayoutConstraint?
    
    private var oldConstraint2: NSLayoutConstraint?
    private var oldConstraint3: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
        // Initialization code
        self.questionImageView1.hidden = true
        self.questionImageView2.hidden = true
        self.questionImageView3.hidden = true
        
        self.oldConstraint2 = self.questionImageConstraint2
        self.oldConstraint3 = self.questionImageConstraint3
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.aspectConstraint1 = nil
        self.aspectConstraint2 = nil
        self.aspectConstraint3 = nil
        self.questionImageView2.image = nil
        self.questionImageView3.image = nil
        
        if self.questionImageConstraint2 == nil {
            self.questionImageConstraint2 = self.oldConstraint2
        }
        if self.questionImageConstraint3 == nil {
            self.questionImageConstraint3 = self.oldConstraint3
        }
        
        self.setNeedsLayout()
        self.updateConstraintsIfNeeded()
    }
    
    internal func configureCell(images: [NSData]) {
        self.insertImages(images: images)
    }
    
    internal var aspectConstraint1: NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                self.questionImageView1.removeConstraint(oldValue!)
            }
            if aspectConstraint1 != nil {
                self.questionImageView1.addConstraint(aspectConstraint1!)
            }
        }
    }
    
    internal var aspectConstraint2: NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                self.questionImageView2.removeConstraint(oldValue!)
            }
            if aspectConstraint2 != nil {
                if self.questionImageConstraint2 != nil {
                    self.questionImageView2.removeConstraint(self.questionImageConstraint2!)
                }
                self.questionImageView2.addConstraint(aspectConstraint2!)
            }
        }
    }
    
    internal var aspectConstraint3: NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                self.questionImageView3.removeConstraint(oldValue!)
            }
            if aspectConstraint3 != nil {
                if self.questionImageConstraint3 != nil {
                    self.questionImageView3.removeConstraint(self.questionImageConstraint3!)
                }
                self.questionImageView3.addConstraint(aspectConstraint3!)
            }
        }
    }
    
    private func insertImages(images images: [NSData]) {
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        let hash_str = username + ":" + SECRET_KEY
        let hash_key = MD5Digester.digest(hash_str)
        
        if images.count >= 1 {
            let decodedData = NSData(base64EncodedData: images[0], options: NSDataBase64DecodingOptions.init(rawValue: 0))
            
            do {
                
                let originalImage = try RNCryptor.decryptData(decodedData!, password: hash_key)
                let image = UIImage(data: originalImage)
                
                let ratio = (image?.size.width)! / (image?.size.height)!
                self.questionImageView1.hidden = false
                self.questionImageView1.image = image
                self.aspectConstraint1 = NSLayoutConstraint(item: self.questionImageView1, attribute: .Width, relatedBy: .Equal, toItem: self.questionImageView1, attribute: .Height, multiplier: ratio, constant: 0.0)
            } catch {}
            
        }
        if images.count >= 2 {
            let decodedData = NSData(base64EncodedData: images[1], options: NSDataBase64DecodingOptions.init(rawValue: 0))
            
            do {
                let originalImage = try RNCryptor.decryptData(decodedData!, password: hash_key)
                let image = UIImage(data: originalImage)
                
                let ratio = (image?.size.width)! / (image?.size.height)!
                self.questionImageView2.hidden = false
                self.questionImageView2.image = image
                self.aspectConstraint2 = NSLayoutConstraint(item: self.questionImageView2, attribute: .Width, relatedBy: .Equal, toItem: self.questionImageView2, attribute: .Height, multiplier: ratio, constant: 0.0)
                
            } catch {}
        }
        if images.count >= 3 {
            let decodedData = NSData(base64EncodedData: images[2], options: NSDataBase64DecodingOptions.init(rawValue: 0))
            
            do {
                let originalImage = try RNCryptor.decryptData(decodedData!, password: hash_key)
                let image = UIImage(data: originalImage)
                
                let ratio = (image?.size.width)! / (image?.size.height)!
                self.questionImageView3.hidden = false
                self.questionImageView3.image = image
                self.aspectConstraint3 = NSLayoutConstraint(item: self.questionImageView3, attribute: .Width, relatedBy: .Equal, toItem: self.questionImageView3, attribute: .Height, multiplier: ratio, constant: 0.0)
                
            } catch {}
        }
        
        //        self.setNeedsUpdateConstraints()
        //        self.updateConstraints()
        //        self.sizeToFit()
        //        self.setNeedsLayout()
    }

}
