//
//  PhotoViewController.swift
//  ImageFilter
//
//  Created by Jisoo Hong on 2015. 4. 6..
//  Copyright (c) 2015년 JHK. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDataSource, ImageSelectedDelegate {
  
  var alertController = UIAlertController(title: "Filters", message: "Pick a filter to apply", preferredStyle: UIAlertControllerStyle.ActionSheet)
//MARK: Photoview contraint outlets
  @IBOutlet weak var photoViewTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var photoViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var photoViewTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var photoViewLeadingConstraint: NSLayoutConstraint!
//MARK:
  @IBOutlet weak var collectionView: UICollectionView!
//MARK: Collectionview constraint outlet
  @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var optionsButton: UIButton!
  @IBOutlet weak var photoImageView: UIImageView!
  let photoViewBuffer : CGFloat = 35
  let photoViewAnimationDuration = 0.3
  var photoViewOriginalTopTrailingLeadingConstraint : CGFloat = 0.0
  var photoViewOriginalBottomConstraint : CGFloat = 0.0
  var collectionViewHeight : CGFloat = 75
  let collectionViewFilterModeBottomConstant : CGFloat = 8
  let thumbnailImageSize : CGSize = CGSize(width: 75, height: 75)
  
  var filters : [(UIImage,CIContext)->UIImage]!
  var context : CIContext!
  
  var thumbnailImage : UIImage!
  var currentImage: UIImage!{
    didSet{
      self.photoImageView.image = self.currentImage
      thumbnailImage = ImageResizer.resizeImage(self.currentImage, size: self.thumbnailImageSize)
      self.collectionView.reloadData()
    }
  }
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
      self.collectionView.dataSource = self
      self.collectionViewBottomConstraint.constant = -self.tabBarController!.tabBar.frame.height - self.collectionView.frame.height
      self.photoViewOriginalTopTrailingLeadingConstraint = self.photoViewTopConstraint.constant
      self.photoViewOriginalBottomConstraint = self.photoViewBottomConstraint.constant
      
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
          let photoPicker = UIImagePickerController()
          photoPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
          photoPicker.allowsEditing = true
          photoPicker.delegate = self
          self.presentViewController(photoPicker, animated: true, completion: nil)
        }
        alertController.addAction(cameraAction)
      }
      
      let firstFilterAction = UIAlertAction(title: "Filters", style: UIAlertActionStyle.Default) { (action) -> Void in
        //let filteredImage = FilterService.ApplySepiaFilter(self.photoImageView.image!)
        //self.photoImageView.image = filteredImage
        self.enterFilterMode()
        
      }
      
      let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
      }
      alertController.addAction(firstFilterAction)
      alertController.addAction(cancelAction)
      
      
      let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default){ (action) -> Void in
        self.performSegueWithIdentifier("ShowGallery", sender: self)
      }
      alertController.addAction(galleryAction)
      
      let uploadAction = UIAlertAction(title: "Upload", style: UIAlertActionStyle.Default) { (action) -> Void in
        
        let resizedImage = ImageResizer.resizeImage(self.photoImageView.image!, size: CGSize(width: 400, height: 400))
        let imageData = UIImageJPEGRepresentation(resizedImage, 1.0)
        let imageFile = PFFile(name: "post.jpg", data: imageData)
        let post = PFObject(className: "Post")
        post["image"] = imageFile
        post.saveInBackgroundWithBlock({ (finished, error) -> Void in
          if error != nil{
            
          }else{
            println("image uploaded")
          }
        })
      }
      alertController.addAction(uploadAction)
      
      let option = [kCIContextWorkingColorSpace: NSNull()]
      let myEAGLContext =  EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
      context = CIContext(EAGLContext: myEAGLContext, options: option)
      filters = [FilterService.Sepia,FilterService.Pixelate,FilterService.Bloom, FilterService.Noir, FilterService.Chrome]
      self.currentImage = UIImage(named: "stars.jpg")
      

    }
  
  @IBAction func alertButtonPressed(sender: AnyObject) {
    
    if let popoverViewController = self.alertController.popoverPresentationController {
      if let button = sender as? UIButton{
        popoverViewController.sourceView = button
        popoverViewController.sourceRect = button.bounds
      }
    }
   
    self.presentViewController(alertController, animated: true) { () -> Void in
      
    }
    
  }
  
  func enterFilterMode(){
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "exitFilterMode")
    self.optionsButton.enabled = false
    self.photoViewTopConstraint.constant = self.photoViewTopConstraint.constant + self.photoViewBuffer
    self.photoViewBottomConstraint.constant = self.photoViewBottomConstraint.constant + self.photoViewBuffer
    self.photoViewLeadingConstraint.constant = self.photoViewLeadingConstraint.constant + self.photoViewBuffer
    self.photoViewTrailingConstraint.constant = self.photoViewTrailingConstraint.constant + self.photoViewBuffer
    self.collectionViewBottomConstraint.constant = self.collectionViewFilterModeBottomConstant
    UIView.animateWithDuration(self.photoViewAnimationDuration, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
  }
  
  func exitFilterMode(){
    println("Done button pressed")
    self.navigationItem.rightBarButtonItem = nil
    self.optionsButton.enabled = true
    self.photoViewTopConstraint.constant = self.photoViewOriginalTopTrailingLeadingConstraint
    self.photoViewLeadingConstraint.constant = self.photoViewOriginalTopTrailingLeadingConstraint
    self.photoViewTrailingConstraint.constant = self.photoViewOriginalTopTrailingLeadingConstraint
    self.photoViewBottomConstraint.constant = self.photoViewOriginalBottomConstraint
    self.collectionViewBottomConstraint.constant = -self.tabBarController!.tabBar.frame.height - self.collectionView.frame.height
    UIView.animateWithDuration(self.photoViewAnimationDuration, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })

  }
  
  //MARK:
  //MARK: UIImagePickerControllerDelegate
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    self.currentImage = info[UIImagePickerControllerEditedImage] as? UIImage
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  //MARK:
  //MARK: UICollectionViewDataSource
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    var cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilteredCell", forIndexPath: indexPath) as FilteredViewCell
    let filter = filters[indexPath.row]
    cell.thumbnailImage.image = filter(self.thumbnailImage,self.context)
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filters.count
  }
  
  //MARK:
  //MARK: ImageSelectedDelegate
  
  func controllerDidSelectImage(image: UIImage) {
    self.currentImage = image
  }
  
  //MARK:
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowGallery"{
      let galleryViewController = segue.destinationViewController as GalleryViewController
      galleryViewController.mainImageSize = self.photoImageView.image!.size
      galleryViewController.delegate = self
    }
  }
  
}
