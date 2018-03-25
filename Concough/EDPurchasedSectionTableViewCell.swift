//
//  EDPurchasedSectionTableViewCell.swift
//  Concough
//
//  Created by Owner on 2017-01-10.
//  Copyright © 2017 Famba. All rights reserved.
//
import UIKit

class EDPurchasedSectionTableViewCell: UITableViewCell {

    private var totalCount: Float = 0.0
    
    @IBOutlet weak var downloadCountLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var purchaseTime: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var loadingStackView: UIStackView!
    @IBOutlet weak var downloadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var refreshPurchaseButton: UIButton!
    @IBOutlet weak var loadingPurchaseIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
    override func drawRect(rect: CGRect) {
        self.downloadButton.layer.cornerRadius = 3.0
        self.downloadButton.layer.masksToBounds = true
    }
    
    internal func configureCell(purchased purchased: EntrancePrurchasedStructure) {
        self.downloadCountLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(purchased.downloaded!)! + " دانلود"
        self.purchaseTime.text = FormatterSingleton.sharedInstance.IRDateFormatter.stringFromDate(purchased.created!)
        
        self.refreshPurchaseButton.hidden = false
        self.loadingPurchaseIndicator.hidden = true
    }
    
    internal func changeToDownloadState(total total: Int) {
        self.downloadButton.hidden = true
        self.progressView.hidden = false
        self.progressView.setProgress(0.0, animated: true)
        self.loadingPurchaseIndicator.hidden = true
        self.refreshPurchaseButton.hidden = true        
        self.totalCount = Float(total)
    }
    
    internal func changeProgressValue(value value: Int) {
        let delta = (self.totalCount - Float(value)) / self.totalCount
        self.progressView.setProgress(delta, animated: true)
    }
    
    internal func changeToDownloadStartedState() {
        self.downloadButton.hidden = true
        self.progressView.hidden = true
        self.loadingStackView.hidden = false
        self.loadingPurchaseIndicator.hidden = true
        self.refreshPurchaseButton.hidden = true
        self.downloadingIndicator.startAnimating()
    }
    
    internal func showLoading(flag flag: Bool) {
        if flag == true {
            self.loadingPurchaseIndicator.hidden = false
            self.refreshPurchaseButton.hidden = true
        } else {
            self.loadingPurchaseIndicator.hidden = true
            self.refreshPurchaseButton.hidden = false
        }
        
        self.setNeedsLayout()
    }
    
    internal func updateDownloadedLabel(count count: Int) {
        self.downloadCountLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(count)! + " دستگاه"
        self.setNeedsLayout()
    }
}
