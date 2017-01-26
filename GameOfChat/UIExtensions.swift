//
//  UIExtensions.swift
//  GameOfChat
//
//  Created by Anselme Kotchap on 2017/01/15.
//  Copyright © 2017 MIND. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}


let imageCache = NSCache< NSString, UIImage>()

extension UIImageView {
    
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil
    
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            
            self.image = cachedImage
            return
        }
        
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            //download hit an error, let's return
            if let err = error {
                
                print(err)
                return
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!) {
                    
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                }
            }
        }.resume()
        
    }
}
