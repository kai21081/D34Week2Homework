//
//  FilterService.swift
//  ImageFilter
//
//  Created by Jisoo Hong on 2015. 4. 7..
//  Copyright (c) 2015년 JHK. All rights reserved.
//

import UIKit
import CoreImage

class FilterService {
  
  class func Sepia(image: UIImage, context: CIContext) -> UIImage{
    
    var filter = CIFilter(name: "CISepiaTone")
    return self.ApplyFilter(image, filter:filter, context: context)
  }
  
  class func Pixelate(image: UIImage, context: CIContext) -> UIImage{
    var filter = CIFilter(name: "CIPixellate")
    return self.ApplyFilter(image, filter:filter, context: context)
  }
  
  class func Bloom(image: UIImage, context: CIContext) -> UIImage{
    var filter = CIFilter(name: "CIBloom")
    return self.ApplyFilter(image, filter:filter, context: context)
  }
  
  class func Noir(image: UIImage, context: CIContext) -> UIImage{
    var filter = CIFilter(name: "CIPhotoEffectNoir")
    return self.ApplyFilter(image, filter: filter, context: context)
  }
  
  class func Chrome(image: UIImage, context: CIContext) -> UIImage{
    var filter = CIFilter(name: "CIPhotoEffectChrome")
    return self.ApplyFilter(image, filter: filter, context: context)
  }
  
  private class func ApplyFilter(image: UIImage, filter : CIFilter, context : CIContext) -> UIImage{
    var image = CIImage(image: image)
    filter.setValue(image, forKey: kCIInputImageKey)
    var imageOut = filter.valueForKey(kCIOutputImageKey) as CIImage
    let result = context.createCGImage(imageOut, fromRect: imageOut.extent())
    
    return UIImage(CGImage: result)!
  }
}
