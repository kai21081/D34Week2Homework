//
//  ImageResizer.swift
//  ImageFilter
//
//  Created by Jisoo Hong on 2015. 4. 7..
//  Copyright (c) 2015년 JHK. All rights reserved.
//

import UIKit

class ImageResizer {
  class func resizeImage(originalImage: UIImage, size : CGSize) -> UIImage{
    
    UIGraphicsBeginImageContext(size)
    originalImage.drawInRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
    
  }
}