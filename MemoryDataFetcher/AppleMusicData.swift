//
//  File.swift
//  MusicMemories
//
//  Created by Andy on 2025/2/21.
//

import Foundation
import SwiftSoup

func fetchAlbumCover(from url: String, completion: @escaping (String?) -> Void) {
    guard let url = URL(string: url) else {
        print("Invalid URL")
        completion(nil)
        return
    }
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Request failed: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        guard let data = data else {
            print("No data received")
            completion(nil)
            return
        }
        do {
            let document = try SwiftSoup.parse(String(data: data, encoding: .utf8)!)
            let pictures = try document.select("picture.svelte-3e3mdo")
            guard pictures.size() > 0 else {
                print("No picture element found")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            let sources = try pictures[0].select("source[type='image/jpeg']")
            guard sources.size() > 0 else {
                print("No source elements found")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            for source in sources {
                let srcset = try source.attr("srcset")
                let urls = srcset.split(separator: ",")
                if urls.count > 1 {
                    let mediumQualityUrl = urls[1].split(separator: " ")[0]
                    DispatchQueue.main.async {
                        completion(String(mediumQualityUrl))
                    }
                    return
                }
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        } catch {
            print("HTML parsing failed: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    task.resume()
}



func fetchComposer(from url: String, completion: @escaping (String?) -> Void) {
    guard let url = URL(string: url) else {
        print("Invalid URL")
        completion(nil)
        return
    }
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Request failed: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        guard let data = data else {
            print("No data received")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        do {
            let document = try SwiftSoup.parse(String(data: data, encoding: .utf8)!)
            if let subtitlesElement = try document.select("div[data-testid='product-subtitles']").first() {
                if let composerLink = try subtitlesElement.select("a.click-action").first() {
                    let composerName = try composerLink.text()
                    DispatchQueue.main.async {
                        completion(composerName)
                    }
                } else {
                    print("Composer information not found")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } else {
                print("product-subtitles element not found")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        } catch {
            print("HTML parsing failed: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    task.resume()
}


func fetchSongName(from url: String, completion: @escaping (String?) -> Void) {
    guard let url = URL(string: url) else {
        print("Invalid URL")
        completion(nil)
        return
    }
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Request failed: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        guard let data = data else {
            print("No data received")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        do {
            let document = try SwiftSoup.parse(String(data: data, encoding: .utf8)!)
            let metaElement = try document.select("meta[name=apple:title]").first()
            if let metaContent = try metaElement?.attr("content") {
                DispatchQueue.main.async {
                    completion(metaContent)
                }
            } else {
                print("Meta tag for apple:title not found")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        } catch {
            print("HTML parsing failed: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    task.resume()
}

