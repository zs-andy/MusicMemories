import SwiftUI
import SwiftData
import CoreML
import TipKit

@main
struct MyApp: App {
    private let modelContainer: ModelContainer
    @StateObject private var modelManager = ModelManager()
    init() {
        do {
            try Tips.configure()
            let modelContainer = try ModelContainer(
        for: Memory.self)
            self.modelContainer = modelContainer
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelManager)
        }
        .modelContainer(modelContainer)
    }
}

class ModelManager: ObservableObject {
    @Published var detector: YOLOv3TinyFP16?

    init() {
        loadModel()
    }

    private func loadModel() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let detector = try YOLOv3TinyFP16(configuration: .init())
                DispatchQueue.main.async {
                    self.detector = detector
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to load model: \(error)")
                }
            }
        }
    }
}
