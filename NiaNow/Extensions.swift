//
//  Extensions.swift
//  NiaNow
//
//  Created by David Brownstone on 25/07/2017.
//  Copyright © 2017 David Brownstone. All rights reserved.
//

import UIKit

extension UIColor {
    
    
    /**
     allows a color request without the addition of division by 255 
    */
    convenience init(r: CGFloat, g: CGFloat, b:CGFloat, a:CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
    }

    
    static var themeGreenColor: UIColor {
        return UIColor(r:0, g:104, b:51, a: 1)
    }

    static var themeRedColor: UIColor {
        return UIColor(r: 197, g: 51, b: 42, a: 0.25)
    }
    
    static var themeBubbleBlueColor: UIColor {
        return UIColor(r: 50, g: 150, b: 252, a: 1)
    }
}

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    /**
     loads an image from cache if it already exists there
     
     - Parameter urlString: Firebase URL for this image
    */
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil
        // first check cache for image
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) {
            self.image = cachedImage as? UIImage
            return
        }
        let url = NSURL(string:urlString)
        let urlRequest = URLRequest(url: url! as URL)
        URLSession.shared.dataTask(with: urlRequest as URLRequest, completionHandler: { (data, response, error) in
            if error != nil {
                print(error ?? "incorrect URL request" )
                return
            }
            DispatchQueue.main.sync {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            }
        }).resume()
    }
    
}
