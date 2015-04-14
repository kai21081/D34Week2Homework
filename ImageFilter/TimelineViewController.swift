//
//  TimelineViewController.swift
//  ImageFilter
//
//  Created by Jisoo Hong on 2015. 4. 14..
//  Copyright (c) 2015년 JHK. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!
  var images = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
      tableView.dataSource = self
      let query = PFQuery(className: "Post")
      query.findObjectsInBackgroundWithBlock { [weak self] (results, error) -> Void in
        if error != nil {
          println(error.localizedDescription)
        } else {
          if self != nil{
            for object in results{
              var obj = object as PFObject
              var imageFile = obj["image"] as PFFile
              var image = UIImage(data:imageFile.getData())
              self!.images.append(image!)
            }
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
              self!.tableView.reloadData()
            })
            
          }
          //println(results.count)
          
        }
      }
        // Do any additional setup after loading the view.
    }
  
  //MARK:
  //MARK: UITableViewDataSource
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return images.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as TimelineViewCell
    let image = images[indexPath.row]
    cell.timelineImage.image = image
    return cell
    
  }

}
