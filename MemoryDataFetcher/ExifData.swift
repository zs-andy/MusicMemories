//
//  ExifData.swift
//  MusicMemories
//
//  Created by Andy on 2025/2/21.
//

import Foundation
import ImageIO

func getImageDate(from imageData: Data) -> Date? {
    let cfData = imageData as CFData
    guard let imageSource = CGImageSourceCreateWithData(cfData, nil) else { return nil }
    
    if let metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any],
       let exif = metadata[kCGImagePropertyExifDictionary as String] as? [String: Any] {

        if let dateTimeString = exif[kCGImagePropertyExifDateTimeOriginal as String] as? String {
            return convertExifDateToDate(dateTimeString)
        }
    }
    
    return nil
}

func convertExifDateToDate(_ dateString: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
    return dateFormatter.date(from: dateString)
}

func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter.string(from: date)
}
