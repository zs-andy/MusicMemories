//
//  File.swift
//  Music Memories
//
//  Created by Andy on 2025/2/23.
//

import Foundation
import TipKit

struct EditPhotoTip: Tip{
    static let presentEvent = Event(id: "present")
    var title: Text{
        Text("Change Picture")
    }
    var message: Text?{
        Text("You can tap the image to edit it.")
    }
    var rules: [Rule]{
        #Rule(Self.presentEvent) { event in
            event.donations.count == 1
        }
    }
}

struct MusicTip: Tip{
    static let presentEvent = Event(id: "present2")
    var title: Text{
        Text("Set Music")
    }
    var message: Text?{
        Text("Copy the sharing link of a song from Apple Music to automatically fetch its information, or simply click the icon to manually add the album cover and enter the song details.")
    }
    var rules: [Rule]{
        #Rule(Self.presentEvent) { event in
            event.donations.count == 1
        }
    }
}

struct EmojiTip: Tip{
    static let presentEvent = Event(id: "present3")
    var title: Text{
        Text("Show Emoji")
    }
    var message: Text?{
        Text("Click on the date to choose whether to show the Emoji or not.")
    }
    var rules: [Rule]{
        #Rule(Self.presentEvent) { event in
            event.donations.count == 1
        }
    }
}
