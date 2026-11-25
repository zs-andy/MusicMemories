<div align="center">

# Music Memories

**Swift Student Challenge 2025 参赛作品 — 用端侧 Core ML（YOLOv3）主体识别与 SwiftData，把照片和旋律封存为专属音乐记忆。**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Swift Student Challenge](https://img.shields.io/badge/Apple-Swift%20Student%20Challenge%202025-111827.svg)](#项目简介)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20iPadOS%2017%2B-0A84FF.svg)](#运行环境与本地构建)
[![Core ML](https://img.shields.io/badge/Core%20ML-YOLOv3TinyFP16-F05138.svg)](#项目结构)

[English](README.md) | **简体中文**

</div>

---

## 项目简介

一首歌常常能瞬间唤起某段时光的记忆。**Music Memories** 是为 Apple **Swift Student Challenge 2025** 打造的 Swift Playgrounds 应用，将日常照片与当下的音乐绑定为可回顾的记忆卡片：

- **端侧主体识别（`SubjectDetector.swift`）**：内置 **Core ML `YOLOv3TinyFP16`** 模型，在本地对导入照片执行 `416×416` 目标检测，自动识别画面主体。
- **自动读取 EXIF 与音乐封面**：解析照片 EXIF 拍摄时间与地点（`MemoryDataFetcher/ExifData.swift`），并通过 `SwiftSoup` 解析 Apple Music 链接的歌曲封面与信息（`MemoryDataFetcher/AppleMusicData.swift`）。
- **本地记忆库（`DataModel.swift`）**：使用 `SwiftData` 持久化照片、故事文本、歌曲、歌手、专辑封面、地点与情绪 Emoji，并结合 `TipKit` 提供轻盈的交互引导。

## 项目结构

```text
MusicMemories/
├── Package.swift                    # Swift Playgrounds App Package（iOS 17+，Swift 6）
├── MyApp.swift                      # 应用入口、SwiftData 容器与 Core ML 异步加载
├── DataModel.swift                  # @Model Memory 数据模型
├── SubjectDetector.swift            # 端侧 Core ML YOLOv3TinyFP16 图像预处理与推理
├── AppTip.swift                     # TipKit 引导提示
├── MLModel/YOLOv3TinyFP16.mlmodel   # 内置 Core ML 目标检测模型
├── MemoryDataFetcher/
│   ├── AppleMusicData.swift         # Apple Music 封面与元数据解析（SwiftSoup）
│   └── ExifData.swift               # 照片 EXIF 时间与地点提取
└── View/
    ├── ContentView.swift            # 音乐记忆时间流主界面
    ├── AddMemoryView.swift          # 新建记忆卡片
    └── EditMemoryView.swift         # 编辑已有记忆
```

## 运行环境与本地构建

- **Xcode 16+** 或 **Swift Playgrounds 4.5+**（macOS / iPadOS）
- **iOS / iPadOS 17.0+**

```sh
git clone https://github.com/zs-andy/MusicMemories.git
open MusicMemories/Package.swift
```

在 Xcode 中选择 iPhone / iPad 模拟器或真机，按 **⌘R** 运行即可。

## 参与贡献

欢迎大家一起扩展和打磨：

- **接入官方 MusicKit / Spotify**：替代 `AppleMusicData.swift` 中的网页解析，并支持多音乐平台链接。
- **卡片内试听播放**：支持直接试听每条记忆绑定的 30 秒片段。
- **升级端侧视觉模型**：替换为 Apple Vision 主体分割或更新一代 YOLO Core ML 模型。
- **记忆海报导出与分享**。

详见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 开源协议

基于 [MIT License](LICENSE) 开源。
