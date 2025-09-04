import SwiftUI
import SwiftData

extension ContentView {
    @MainActor
    class ContentViewModel: ObservableObject {
        @Published var index_: Int = 0
    }
}

struct ContentView: View {
    @State var AddMemoryPresent = false
    @State var EditMemoryPresent = false
    @Query var memorydata: [Memory] = []
    @State private var scrollOffset: CGFloat = 0
    @StateObject private var viewModel = ContentViewModel()
    
    @Environment(\.modelContext) private var modelContext
    
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
                LazyVStack{
                    ForEach(memorydata.indices, id: \.self) { index in
                        if let photo = memorydata[index].photo, let uiImage = UIImage(data: photo){
                            Button(action:{
                                EditMemoryPresent = true
                                viewModel.index_ = index
                            }){
                                VStack{
                                    ZStack(alignment: .bottomLeading){
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .shadow(radius: 1)
                                    }
                                    HStack{
                                        if let cover = memorydata[index].albumcover, let uiCover = UIImage(data: cover) {
                                            Image(uiImage: uiCover)
                                                .resizable()
                                                .frame(width: 70, height: 70)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .padding(.leading)
                                                .padding(.top, 5)
                                                .shadow(radius: 1)
                                        }else{
                                            ZStack{
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .frame(width: 70, height: 70)
                                                    .foregroundStyle(.thinMaterial)
                                                Image(systemName: "music.note")
                                                    .foregroundStyle(Color.gray)
                                                    .font(.system(size: 30))
                                            }
                                            .padding(.top, 5)
                                            .padding(.leading)
                                        }
                                        VStack(alignment:.leading){
                                            Text(memorydata[index].songs)
                                                .bold()
                                                .padding(.top, 5)
                                                .font(.system(size: 15))
                                                .foregroundStyle(Color.black)
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(2)
                                            Text(memorydata[index].artist)
                                                .font(.system(size: 10))
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                                .offset(y :2)
                                            Spacer()
                                        }
                                        .padding(.leading, 5)
                                        Spacer()
                                        Button(action: {
                                            if let url = URL(string: memorydata[index].URL) {
                                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                            }
                                        }) {
                                            ZStack{
                                                if memorydata[index].URL != "" {
                                                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                                                        .frame(width: 50, height: 50)
                                                        .foregroundStyle(.thinMaterial)
                                                    Image(systemName: "play.circle")
                                                        .foregroundStyle(Color.gray)
                                                        .font(.system(size: 25))
                                                }else{
                                                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                                                        .frame(width: 50, height: 50)
                                                        .foregroundStyle(.clear)
                                                }
                                            }
                                            .padding(.top, 5)
                                            .padding(.horizontal)
                                        }
                                    }
                                    HStack(){
                                        VStack(alignment: .leading) {
                                            if memorydata[index].emojiIsPresent{
                                                Text("\(formattedDate(getImageDate(from: photo) ?? Date())) \(memorydata[index].emoji)")
                                                    .font(.headline)
                                                    .foregroundColor(.secondary)
                                            }else{
                                                Text(formattedDate(getImageDate(from: photo) ?? Date()))
                                                    .font(.headline)
                                                    .foregroundColor(.secondary)
                                            }
                                            Text(memorydata[index].title)
                                                .font(.title)
                                                .fontWeight(.black)
                                                .foregroundColor(.primary)
                                                .lineLimit(1)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Text(memorydata[index].content)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .lineLimit(1)
                                        }
                                        .layoutPriority(100)
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                }
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.1), lineWidth: 1)
                                )
                                .padding(.horizontal)
                                .padding(.top)
                            }
                            .fullScreenCover(isPresented: $EditMemoryPresent, content: {
                                EditMemoryView(EditMemoryPresent: $EditMemoryPresent, memory: memorydata[viewModel.index_])
                            })
                        }
                    }
                }
                .padding(.top, 70)
                .padding(.bottom, 100)
            }
            VStack {
                HStack {
                    HStack {
                        Text("Memories")
                            .font(.system(size: max(40 + scrollOffset / 10, 30)))
                            .bold()
                            .padding(.horizontal)
                            .animation(.easeInOut, value: scrollOffset)
                            .opacity(opacityValue())
                        Spacer()
                    }
                    Spacer()
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 20, style: .continuous)
//                            .foregroundStyle(.thinMaterial)
//                            .frame(width: 50, height: 50)
//                            .padding(.trailing)
//                        Button(action: {
//                            
//                        }) {
//                            Image(systemName: "magnifyingglass")
//                                .foregroundStyle(Color.black)
//                                .font(.system(size: 20))
//                        }
//                        .padding(.trailing)
//                    }
                }
                .offset(y: 17)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack{
                Spacer()
                Button(action:{
                    AddMemoryPresent = true
                }){
                    ZStack {
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .foregroundStyle(.thinMaterial)
                            .frame(width: 70, height: 70)
                        Button(action: {
                            AddMemoryPresent = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundStyle(Color.black)
                                .font(.system(size: 25))
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .fullScreenCover(isPresented: $AddMemoryPresent, content: {
                AddMemoryView(AddMemoryPresent: $AddMemoryPresent)
            })
                            
        }
    }
    
    func opacityValue() -> Double{
        return max(0, (40 + scrollOffset)/40)
    }
}
