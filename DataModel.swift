//
//  File.swift
//  MusicMemories
//
//  Created by Andy on 2025/2/16.
//

import Foundation
import SwiftData

@Model
class Memory: Identifiable{
    var id = UUID()
    
    var title: String
    var content: String
    var songs: String
    var artist: String
    var albumcover: Data?
    var photo: Data?
    var date: Date
    var location: String?
    var URL: String
    var emoji: String
    var emojiIsPresent: Bool
    
    init(id: UUID = UUID(), title: String, content: String, songs: String, artist: String, albumcover: Data? = nil, photo: Data? = nil, date: Date, location: String? = nil, URL: String, emoji: String, emojiIsPresent: Bool) {
        self.id = id
        self.title = title
        self.content = content
        self.songs = songs
        self.artist = artist
        self.albumcover = albumcover
        self.photo = photo
        self.date = date
        self.location = location
        self.URL = URL
        self.emoji = emoji
        self.emojiIsPresent = emojiIsPresent
    }
}


