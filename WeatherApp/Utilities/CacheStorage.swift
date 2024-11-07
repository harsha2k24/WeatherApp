//
//  CacheStorage.swift
//  WeatherApp
//
//  Created by Harsha on 11/06/24.
//

import Foundation
import UIKit

public class CacheStorage {
    
    fileprivate init() { }
    
    enum Directory {
        case documents
        case caches
    }
    
    /// Returns URL constructed from specified directory
    static fileprivate func getURL(for directory: Directory) -> URL {
        var searchPathDirectory: FileManager.SearchPathDirectory
        
        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .caches:
            searchPathDirectory = .cachesDirectory
        }
        
        if let url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Could not create URL for specified directory!")
        }
    }
    
    
    /// Store an encodable struct to the specified directory on disk
    ///
    /// - Parameters:
    ///   - object: the encodable struct to store
    ///   - directory: where to store the struct
    ///   - fileName: what to name the file where the struct data will be stored
    static func store<T: Codable>(_ object: T, to directory: Directory, as fileName: String) {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Retrieve and convert a struct from a file on disk
    ///
    /// - Parameters:
    ///   - fileName: name of the file where struct data is stored
    ///   - directory: directory where struct data is stored
    ///   - type: struct type (i.e. Message.self)
    /// - Returns: decoded struct model(s) of data
    static func retrieve<T: Codable>(_ fileName: String, from directory: Directory, as type: T.Type) -> T? {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }
        
        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                print(error.localizedDescription)
                return nil
            }
        } else {
            return nil
        }
    }
    
    /// Remove all files at specified directory
    static func clear(_ directory: Directory) {
        let url = getURL(for: directory)
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for fileUrl in contents {
                try FileManager.default.removeItem(at: fileUrl)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Remove specified file from specified directory
    static func remove(_ fileName: String, from directory: Directory) {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    /// Returns BOOL indicating whether file exists at specified directory with specified file name
    static func fileExists(_ fileName: String, in directory: Directory) -> Bool {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        return FileManager.default.fileExists(atPath: url.path)
    }
    /// Store an image as Data to the specified directory
    static func storeImage(_ image: UIImage, to directory: Directory, as fileName: String) {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        
        if let imageData = image.jpegData(compressionQuality: 1.0) { // You can use .pngData() if you want PNG format
            if FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: imageData, attributes: nil)
        } else {
            print("Error: Could not convert image to data")
        }
    }
    
    /// Retrieve an image from the specified directory
    static func retrieveImage(from directory: Directory, fileName: String) -> UIImage? {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        
        if let data = FileManager.default.contents(atPath: url.path), let image = UIImage(data: data) {
            return image
        }
        
        return nil
    }
    
    /// Remove specified image file from specified directory
    static func removeImage(_ fileName: String, from directory: Directory) {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
