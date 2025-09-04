//
//  File.swift
//  MusicMemories
//
//  Created by Andy on 2025/2/17.
//

import Foundation
import SwiftUI
import PhotosUI
import ImageIO
import SwiftData
import TipKit

struct AddMemoryView: View {
    @Binding var AddMemoryPresent: Bool
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    @State private var scrollOffset: CGFloat = 0

    @State var selectedItem: PhotosPickerItem? = nil
    @State var selectedCover: PhotosPickerItem? = nil
    @State var selectedImageData: Data? = nil
    @State var selectedCoverData: Data? = nil
    @State var memory: Memory = Memory(title: "", content: "", songs: "", artist: "", albumcover: nil, photo: nil, date: Date(), location: nil, URL: "", emoji: "", emojiIsPresent: true)
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var modelManager: ModelManager
    
    let editPhotoTip = EditPhotoTip()
    let musicTip = MusicTip()
    let emojiTip = EmojiTip()
    let emojis = [
        "👤", "🚲", "🚗", "🏍️", "✈️", "🚍", "🚆", "🚚", "🚤", "🚦", "🚒", "🛑",
        "🅿️", "🛋️", "🦅", "🐱", "🐶", "🐴", "🐑", "🐄", "🐘", "🐻", "🦓", "🦒",
        "🎒", "☂️", "👜", "👔", "🧳", "🥏", "🎿", "🏂", "🏀", "🪁", "⚾", "🧤",
        "🛹", "🏄‍♂️", "🎾", "🍾", "🍷", "☕", "🍴", "🔪", "🥄", "🍚", "🍌",
        "🍎", "🥪", "🍊", "🥦", "🥕", "🌭", "🍕", "🍩", "🎂", "🪑", "🛋️",
        "🪴", "🛏️", "🍽️", "🚽", "📺", "💻", "🖱️", "📺", "⌨️", "📱",
        "🍲", "🍳", "🍞", "🧼", "🧊", "📚", "⏰", "🌸", "✂️", "🧸", "💇‍♀️", "🪥"
    ]
    
    var body: some View {
        ZStack{
            ScrollView {
                GeometryReader { geometry in
                    Color.clear
                        .onChange(of: geometry.frame(in: .global).minY) { newMinY in
                            self.scrollOffset = newMinY
                        }
                }
                .frame(height: 0)
                VStack{
                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        PhotosPicker(selection: $selectedItem,
                                             matching: .images) {
                            ZStack {
                                ZStack(alignment: .bottomLeading){
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .padding(.horizontal)
                            }
                        }
                        TipView(editPhotoTip)
                            .padding(.horizontal)
                        HStack{
                            if let selectedCoverData, let uiCover = UIImage(data: selectedCoverData) {
                                PhotosPicker(selection: $selectedCover,
                                             matching: .images){
                                    Image(uiImage: uiCover)
                                        .resizable()
                                        .frame(width: 90, height: 90)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .padding(.horizontal)
                                        .padding(.top, 10)
                                }
                            }else{
                                PhotosPicker(selection: $selectedCover,
                                             matching: .images){
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                                            .frame(width: 90, height: 90)
                                            .foregroundStyle(.thinMaterial)
                                        Image(systemName: "music.note")
                                            .foregroundStyle(Color.gray)
                                            .font(.system(size: 40))
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 10)
                                }
                            }
                            VStack{
                                TextField("Name of the Song", text: $memory.songs)
                                    .bold()
                                    .font(.system(size: 20))
                                TextField("Artist", text: $memory.artist)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                TextField("Copy Sharing Link", text: $memory.URL)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.top, 10)
                            .onChange(of: memory.URL) { newUrl in
                                fetchSongName(from: newUrl) { songName in
                                    if let name = songName {
                                        memory.songs = name
                                    } else {
                                        memory.songs = ""
                                        print("Failed to fetch song's name")
                                    }
                                }
                                fetchComposer(from: newUrl) { composerName in
                                    if let name = composerName {
                                        memory.artist = name
                                    } else {
                                        memory.artist = ""
                                        print("Failed to fetch composer")
                                    }
                                }
                                fetchAlbumCover(from: newUrl) { albumCoverURL in
                                    if let urlString = albumCoverURL, let url = URL(string: urlString) {
                                        URLSession.shared.dataTask(with: url) { data, response, error in
                                            if let data = data, error == nil {
                                                DispatchQueue.main.async {
                                                    memory.albumcover = data
                                                    selectedCoverData = data
                                                }
                                            }
                                        }.resume()
                                    }else{
                                        memory.albumcover = nil
                                        selectedCoverData = nil
                                    }
                                }
                            }
                            Spacer()
                        }
                        .onAppear(){
                            Task { await EditPhotoTip.presentEvent.donate() }
                            Task { await MusicTip.presentEvent.donate() }
                        }
                        .onChange(of: selectedCover) { newItem in
                            Task {
                                if let selectedCover, let data = try? await selectedCover.loadTransferable(type: Data.self) {
                                    selectedCoverData = data
                                    memory.albumcover = selectedCoverData
                                }
                            }
                        }
                        TipView(musicTip)
                            .padding(.horizontal)
                        HStack{
                            if memory.emojiIsPresent{
                                Text("\(formattedDate(getImageDate(from: selectedImageData) ?? Date())) \(memory.emoji)")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.leading)
                                    .padding(.top, 10)
                                    .onTapGesture {
                                        memory.emojiIsPresent.toggle()
                                    }
                                    .popoverTip(emojiTip)
                            }else{
                                Text(formattedDate(getImageDate(from: selectedImageData) ?? Date()))
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.leading)
                                    .padding(.top, 10)
                                    .onTapGesture {
                                        memory.emojiIsPresent.toggle()
                                    }
                            }
                            Spacer()
                        }
                        TextField("Title", text: $memory.title, axis: .vertical)
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .lineLimit(3)
                        VStack{
                            TextField("Description of Memory", text: $memory.content,axis: .vertical)
                                .padding(.horizontal)
                                .font(.system(size: 15))
                            Spacer()
                        }
                        .frame(minHeight: 200)
                    } else {
                        PhotosPicker(selection: $selectedItem,
                                             matching: .images) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .padding(.horizontal)
                                    .frame(height: screenWidth * (6 / 4))
                                    .foregroundStyle(.thinMaterial)
                                Image(systemName: "photo.badge.plus")
                                    .foregroundStyle(Color.gray)
                                    .font(.system(size: 30))
                            }
                        }
                    }
                    Spacer()
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let selectedItem, let data = try? await selectedItem.loadTransferable(type: Data.self) {
                            selectedImageData = data
                            memory.photo = selectedImageData
                            if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                let emojiIndex = findSubject(inputImage: uiImage, detector: modelManager.detector!)
                                if emojiIndex != -1 {
                                    memory.emoji = emojis[emojiIndex]
                                    memory.emojiIsPresent = true
                                    Task { await EmojiTip.presentEvent.donate() }
                                }else{
                                    memory.emoji = ""
                                }
                            }
                        }
                    }
                }
                .padding(.top, 80)
            }
            VStack {
                HStack {
                    HStack {
                        Text("New")
                            .font(.system(size: max(40 + scrollOffset / 10, 30)))
                            .bold()
                            .padding(.horizontal)
                            .animation(.easeInOut, value: scrollOffset)
                            .opacity(opacityValue())
                        Spacer()
                    }
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .foregroundStyle(.thinMaterial)
                            .frame(width: 50, height: 50)
                            .padding(.trailing)
                        Button(action: {
                            AddMemoryPresent = false
                            editPhotoTip.invalidate(reason: .actionPerformed)
                            musicTip.invalidate(reason: .actionPerformed)
                        }) {
                            Image(systemName: "bin.xmark.fill")
                                .foregroundStyle(Color.red)
                                .font(.system(size: 20))
                        }
                        .padding(.trailing)
                    }
                    if let selectedImageData, let _ = UIImage(data: selectedImageData) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .foregroundStyle(.thinMaterial)
                                .frame(width: 50, height: 50)
                                .padding(.trailing)
                            Button(action: {
                                modelContext.insert(memory)
                                AddMemoryPresent = false
                                editPhotoTip.invalidate(reason: .actionPerformed)
                                musicTip.invalidate(reason: .actionPerformed)
                            }) {
                                Image(systemName: "checkmark.circle")
                                    .foregroundStyle(Color.black)
                                    .font(.system(size: 20))
                            }
                            .padding(.trailing)
                        }
                    }
                }
                .offset(y: 17)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    func opacityValue() -> Double{
        return max(0, (40 + scrollOffset)/40)
    }
    
}


