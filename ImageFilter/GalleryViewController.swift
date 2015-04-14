//
//  GalleryViewController.swift
//  ImageFilter
//
//  Created by Jisoo Hong on 2015. 4. 14..
//  Copyright (c) 2015년 JHK. All rights reserved.
//

import UIKit
import Photos

protocol ImageSelectedDelegate : class{
  func controllerDidSelectImage(image: UIImage) -> Void
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

  @IBOutlet weak var galleryView: UICollectionView!
  var results : PHFetchResult!
  var imageManager : PHCachingImageManager!
  let cellSize = CGSize(width: 100, height: 100)
  weak var delegate : ImageSelectedDelegate?
  var mainImageSize : CGSize!
  var flowlayout : UICollectionViewFlowLayout!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      self.results = PHAsset.fetchAssetsWithOptions(nil)
      self.galleryView.dataSource = self
      
      self.imageManager = PHCachingImageManager()
      self.galleryView.delegate = self
      
      let pinch = UIPinchGestureRecognizer(target: self, action: "collectionViewPinched:")
      self.galleryView.addGestureRecognizer(pinch)
      self.flowlayout = self.galleryView.collectionViewLayout as UICollectionViewFlowLayout
      

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: UICollectionViewDataSource


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return results.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GalleryCell", forIndexPath: indexPath) as GalleryViewCell
      
      let asset = self.results[indexPath.row] as PHAsset
      self.imageManager.requestImageForAsset(asset, targetSize: cellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
        if image != nil {
          cell.galleryImage.image = image
        }
      }
    
        // Configure the cell
    
        return cell
    }
  
  //MARK: UICollectionViewDelegate
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let asset = self.results[indexPath.row] as PHAsset
    self.imageManager.requestImageForAsset(asset, targetSize: mainImageSize, contentMode: PHImageContentMode.AspectFill, options: nil) { [weak self] (image, info) -> Void in
      if self != nil {
        if image != nil {
          self!.delegate?.controllerDidSelectImage(image)
          self!.navigationController?.popToRootViewControllerAnimated(true)
        }
      }
    }
  }
  
  func collectionViewPinched(pinch : UIPinchGestureRecognizer){
    if pinch.state == UIGestureRecognizerState.Changed {
      let oldSize = self.flowlayout.itemSize
      let newSize = CGSize(width: cellSize.width * pinch.scale, height: cellSize.height * pinch.scale)
      self.flowlayout.itemSize = newSize
      self.galleryView.performBatchUpdates({ () -> Void in
        self.flowlayout.invalidateLayout()
        }, completion: nil)
    }
  }
}
