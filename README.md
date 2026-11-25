<div align="center">

# Music Memories

**A Swift Student Challenge 2025 app that pairs personal photographs with the songs that defined them — using on-device YOLOv3 Core ML subject detection and SwiftData.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Swift Student Challenge](https://img.shields.io/badge/Apple-Swift%20Student%20Challenge%202025-111827.svg)](#overview)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20iPadOS%2017%2B-0A84FF.svg)](#requirements)
[![Core ML](https://img.shields.io/badge/Core%20ML-YOLOv3TinyFP16-F05138.svg)](#architecture)

**English** | [简体中文](README.zh-CN.md)

</div>

---

## Overview

A single track can bring back an entire afternoon, a trip, or a person. **Music Memories** (created for Apple's **Swift Student Challenge 2025**) is an iOS/iPadOS Swift Playgrounds app that turns photos and songs into rich, tactile memory cards:

- **On-Device Subject Detection (`SubjectDetector.swift`)**: Runs a bundled **Core ML `YOLOv3TinyFP16`** model locally on imported photos (`416×416` inference) to detect subjects and enhance memory tagging/composition.
- **Automatic EXIF & Music Metadata**: Extracts capture date & location from photo EXIF metadata (`MemoryDataFetcher/ExifData.swift`) and fetches Apple Music artwork & song details (`MemoryDataFetcher/AppleMusicData.swift` via `SwiftSoup`).
- **SwiftData Memory Vault (`DataModel.swift`)**: Persists titles, notes, photos, song/artist metadata, album art, locations, timestamps, and mood emojis locally with `SwiftData` and interactive `TipKit` hints.

## Project Structure

```text
MusicMemories/
├── Package.swift                    # Swift Playgrounds App Package (iOS 17+, Swift 6)
├── MyApp.swift                      # App entry, SwiftData ModelContainer & async Core ML loader
├── DataModel.swift                  # @Model Memory schema
├── SubjectDetector.swift            # On-device Core ML YOLOv3TinyFP16 image resizing & inference
├── AppTip.swift                     # TipKit onboarding tips
├── MLModel/YOLOv3TinyFP16.mlmodel   # Bundled Core ML object detection model
├── MemoryDataFetcher/
│   ├── AppleMusicData.swift         # Apple Music metadata & album artwork parser (SwiftSoup)
│   └── ExifData.swift               # Photo EXIF timestamp & location extractor
└── View/
    ├── ContentView.swift            # Scrollable memory timeline feed
    ├── AddMemoryView.swift          # Create a photo + song memory
    └── EditMemoryView.swift         # Edit existing memory cards
```

## Requirements & Running Locally

- **Xcode 16+** or **Swift Playgrounds 4.5+** on macOS / iPadOS
- **iOS / iPadOS 17.0+**

```sh
git clone https://github.com/zs-andy/MusicMemories.git
open MusicMemories/Package.swift
```

Select an iPhone or iPad destination in Xcode (or open the folder as a `.swiftpm` app in Swift Playgrounds) and press **⌘R**.

## Contributing

Contributions and forks are welcome! Fun ways to extend **Music Memories**:

- **MusicKit & Spotify support**: Replace HTML scraping in `AppleMusicData.swift` with official `MusicKit` APIs and optional Spotify links.
- **In-app 30-second previews**: Play song previews right from each memory card.
- **Newer Vision / Core ML models**: Upgrade subject detection to Apple's Vision framework or YOLOv8/v11 Core ML exports.
- **Exportable memory posters** for sharing.

See [CONTRIBUTING.md](CONTRIBUTING.md) to get started.

## License

Licensed under the [MIT License](LICENSE).
