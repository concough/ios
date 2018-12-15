//
//  EntranceLessonExamHistoryChartTableViewCell.swift
//  Concough
//
//  Created by Owner on 2018-04-10.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit
import RealmSwift

class EntranceLessonExamHistoryChartTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    private let MAX_LIMIT = 10
    
    @IBOutlet weak var chartCollectionView: UICollectionView!
    
    private var result: Results<EntranceLessonExamModel>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.chartCollectionView.delegate = self
        self.chartCollectionView.dataSource = self
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    internal func configureCell(entranceUniqueId entranceUniqueId: String, lessonTitle: String, lessonOrder: Int, bookletOrder: Int) {
        
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        self.result = EntranceLessonExamModelHandler.getAllExam(username: username, entranceUniqueId: entranceUniqueId, lessonTitle: lessonTitle, lessonOrder: lessonOrder, bookletOrder: bookletOrder, limit: nil)
        
        self.chartCollectionView.reloadData()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.result != nil {
            return 2
        }
        
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            if let cell = self.chartCollectionView.dequeueReusableCellWithReuseIdentifier("ENTRANCE_LESSON_EXAM_HISTORY_CHART_ITEM_2", forIndexPath: indexPath) as? EntranceLessonExamHistoryChartItem2CollectionViewCell {
                
                var labels: [String] = []
                var data: [Double] = []
                
                var i = 0
                for item in self.result! {
                    //                  print   labels.append(FormatterSingleton.sharedInstance.IRDateFormatter.stringFromDate(item.created))
                    labels.append("\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(i + 1)!)")
                    let y = Double(round((round((item.percentage * 10000)) / 100) * 10) / 10)
                    data.append(y)
                    
                    i += 1
                    if i == 10  {
                        break
                    }
                }
                
                
                cell.configureCellAsLine(labels: labels, data: data.reverse())
                return cell
            }
            
        } else if indexPath.row == 1 {
            if let cell = self.chartCollectionView.dequeueReusableCellWithReuseIdentifier("ENTRANCE_LESSON_EXAM_HISTORY_CHART_ITEM", forIndexPath: indexPath) as? EntranceLessonExamHistoryChartItemCollectionViewCell {
                
                var labels: [String] = []
                var data: [[Double]] = []
                
                var i = 0
                for item in self.result! {
                    //                  print   labels.append(FormatterSingleton.sharedInstance.IRDateFormatter.stringFromDate(item.created))
                    labels.append("\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(i + 1)!)")
                    data.append([Double(item.trueAnswer), Double(item.falseAnswer), Double(item.noAnswer)])
                    
                    i += 1
                    if i == 10  {
                        break
                    }
                }
                
                cell.configureCellAsBar(labels: labels, data: data.reverse())
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
}
