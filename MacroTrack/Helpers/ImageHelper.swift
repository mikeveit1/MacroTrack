//
//  ImageHelper.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/8/25.
//

import Foundation
import SwiftUI

extension UIImage: Transferable {
    
    public static var transferRepresentation: some TransferRepresentation {
        
        DataRepresentation(exportedContentType: .png) { image in
            if let pngData = image.pngData() {
                return pngData
            } else {
                // Handle the case where UIImage could not be converted to png.
                throw ConversionError.failedToConvertToPNG
            }
        }
    }
    
    enum ConversionError: Error {
        case failedToConvertToPNG
    }
}


class ImageActivityItemSource: NSObject, UIActivityItemSource {
    let image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    // Provide the image that you want to share
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return image
    }
    
    // Provide the actual image to share
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image
    }
    
    // Optional: Provide the preview for the image when sharing
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "Today's Log"
    }
}
