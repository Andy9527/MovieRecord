//
//  GlobalData.swift
//  MovieRecord
//
//  Created by CHIA CHUN LI on 2021/4/12.
//  Copyright © 2021 李佳駿. All rights reserved.
//

import Foundation
import UIKit

class ImageEdit {
    
    static var imageData:Data!
    static var textViewContent:String!
    static var selectDataKey = ""
    
    static let instance = ImageEdit()

    func resizeAndCompressImageWith(image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat, compressionQuality: CGFloat) -> Data? {

    let horizontalRatio = maxWidth / image.size.width
    let verticalRatio = maxHeight / image.size.height


    let ratio = min(horizontalRatio, verticalRatio)

    let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
    var newImage: UIImage

    if #available(iOS 10.0, *) {
        let renderFormat = UIGraphicsImageRendererFormat.default()
        renderFormat.opaque = false
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: newSize.width, height: newSize.height), format: renderFormat)
        newImage = renderer.image {
            (context) in
            image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        }
    } else {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newSize.width, height: newSize.height), true, 0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    }

    let data = newImage.jpegData(compressionQuality: compressionQuality)



    return data

}

}
