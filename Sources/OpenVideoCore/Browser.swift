import SwiftUI
import Combine

// MARK: - Browser View Model

@MainActor
public final class BrowserViewModel: ObservableObject {
    @Published public var items: [MediaItem] = []
    @Published public var selectedItemIDs: Set<UUID> = []
    @Published public var searchText: String = ""
    @Published public var sortOrder: SortOrder = .name
    @Published public var viewMode: ViewMode = .grid
    @Published public var isLoading = false
    @Published public var currentDirectory: URL?
    @Published public var draggedItems: [MediaItem] = []
    @Published public var importProgress: Double = 0.0
    @Published public var isImporting = false
    @Published public var filterType: MediaType?
    
    public enum SortOrder: String, CaseIterable {
        case name = "Name"
        case date = "Date"
        case duration = "Duration"
        case size = "Size"
    }
    
    public enum ViewMode: String, CaseIterable {
        case list = "List"
        case grid = "Grid"
        case filmstrip = "Filmstrip"
    }
    
    public enum MediaType: String, CaseIterable {
        case video = "Video"
        case audio = "Audio"
        case image = "Image"
    }
    
    public struct MediaItem: Identifiable, Codable, Equatable {
        public let id: UUID
        public let url: URL
        public let name: String
        public let duration: TimeInterval
        public let fileSize: Int64
        public let creationDate: Date
        public let modificationDate: Date
        public let type: MediaType
        public var thumbnail: Data?
        public var resolution: CGSize?
        public var frameRate: Double?
        public var codec: String?
        public var isFavorite: Bool
        
        public init(
            id: UUID = UUID(),
            url: URL,
            name: String,
            duration: TimeInterval = 0,
            fileSize: Int64 = 0,
            creationDate: Date = Date(),
            modificationDate: Date = Date(),
            type: MediaType,
            thumbnail: Data? = nil,
            resolution: CGSize? = nil,
            frameRate: Double? = nil,
            codec: String? = nil,
            isFavorite: Bool = false
        ) {
            self.id = id
            self.url = url
            self.name = name
            self.duration = duration
            self.fileSize = fileSize
            self.creationDate = creationDate
            self.modificationDate = modificationDate
            self.type = type
            self.thumbnail = thumbnail
            self.resolution = resolution
            self.frameRate = frameRate
            self.codec = codec
            self.isFavorite = isFavorite
        }
        
        public var formattedDuration: String {
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
        
        public var formattedFileSize: String {
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            return formatter.string(fromByteCount: fileSize)
        }
        
        public var formattedDate: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: modificationDate)
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var thumbnailCache: [UUID: NSImage] = [:]
    
    public init() {
        setupBindings()
    }
    
    private func setupBindings() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.filterItems()
            }
            .store(in: &cancellables)
        
        $sortOrder
            .sink { [weak self] _ in
                self?.sortItems()
            }
            .store(in: &cancellables)
        
        $filterType
            .sink { [weak self] _ in
                self?.filterItems()
            }
            .store(in: &cancellables)
    }
    
    public var filteredItems: [MediaItem] {
        var result = items
        
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let type = filterType {
            result = result.filter { $0.type == type }
        }
        
        return result
    }
    
    private func filterItems() {
        objectWillChange.send()
    }
    
    private func sortItems() {
        switch sortOrder {
        case .name:
            items.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .date:
            items.sort { $0.modificationDate > $1.modificationDate }
        case .duration:
            items.sort { $0.duration > $1.duration }
        case .size:
            items.sort { $0.fileSize > $1.fileSize }
        }
    }
    
    public func loadDirectory(_ url: URL) async {
        isLoading = true
        currentDirectory = url
        
        do {
            let fileManager = FileManager.default
            let contents = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.contentTypeKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey],
                options: [.skipsHiddenFiles]
            )
            
            var newItems: [MediaItem] = []
            
            for (index, fileURL) in contents.enumerated() {
                let resourceValues = try? fileURL.resourceValues(forKeys: [
                    .contentTypeKey,
                    .fileSizeKey,
                    .creationDateKey,
                    .contentModificationDateKey
                ])
                
                let mediaType = determineMediaType(fileURL)
                
                let item = MediaItem(
                    url: fileURL,
                    name: fileURL.lastPathComponent,
                    duration: await getDuration(for: fileURL),
                    fileSize: Int64(resourceValues?.fileSize ?? 0),
                    creationDate: resourceValues?.creationDate ?? Date(),
                    modificationDate: resourceValues?.contentModificationDate ?? Date(),
                    type: mediaType
                )
                
                newItems.append(item)
                importProgress = Double(index + 1) / Double(contents.count)
            }
            
            items = newItems
            sortItems()
            
            await generateThumbnails()
            
        } catch {
            print("Error loading directory: \(error)")
        }
        
        isLoading = false
        importProgress = 0.0
    }
    
    private func determineMediaType(_ url: URL) -> MediaType {
        let ext = url.pathExtension.lowercased()
        let videoExtensions = ["mp4", "mov", "avi", "mkv", "webm", "m4v", "flv", "wmv"]
        let audioExtensions = ["mp3", "wav", "aac", "m4a", "flac", "ogg"]
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "heic"]
        
        if videoExtensions.contains(ext) { return .video }
        if audioExtensions.contains(ext) { return .audio }
        if imageExtensions.contains(ext) { return .image }
        return .video
    }
    
    private func getDuration(for url: URL) async -> TimeInterval {
        return Double.random(in: 10...300)
    }
    
    private func generateThumbnails() async {
        for index in items.indices {
            guard items[index].type == .video || items[index].type == .image else { continue }
            
            let thumbnail = await generatePlaceholderThumbnail(for: items[index])
            items[index].thumbnail = thumbnail
        }
    }
    
    private func generatePlaceholderThumbnail(for item: MediaItem) async -> Data? {
        await Task.sleep(UInt64(0.01 * 1_000_000_000))
        
        let size = NSSize(width: 320, height: 180)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        let context = NSGraphicsContext.current?.cgContext
        context?.setFillColor(CGColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0))
        context?.fill(CGRect(origin: .zero, size: size))
        
        let text = item.name as NSString
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 14),
            .foregroundColor: NSColor.white
        ]
        text.draw(at: CGPoint(x: 10, y: 10), withAttributes: attributes)
        
        let durationText = item.formattedDuration as NSString
        durationText.draw(at: CGPoint(x: 10, y: 40), withAttributes: attributes)
        
        let typeIcon: String
        switch item.type {
        case .video: typeIcon = "video.fill"
        case .audio: typeIcon = "waveform"
        case .image: typeIcon = "photo.fill"
        }
        
        if let icon = NSImage(systemSymbolName: typeIcon, accessibilityDescription: nil) {
            icon.draw(in: CGRect(x: size.width - 30, y: size.height - 30, width: 20, height: 20))
        }
        
        image.unlockFocus()
        
        return image.tiffRepresentation
    }
    
    public func selectItem(_ id: UUID) {
        selectedItemIDs = [id]
    }
    
    public func toggleSelection(_ id: UUID) {
        if selectedItemIDs.contains(id) {
            selectedItemIDs.remove(id)
        } else {
            selectedItemIDs.insert(id)
        }
    }
    
    public func selectAll() {
        selectedItemIDs = Set(filteredItems.map { $0.id })
    }
    
    public func deselectAll() {
        selectedItemIDs.removeAll()
    }
    
    public func deleteSelected() {
        items.removeAll { selectedItemIDs.contains($0.id) }
        selectedItemIDs.removeAll()
    }
    
    public func toggleFavorite(_ id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].isFavorite.toggle()
        }
    }
    
    public func getSelectedItems() -> [MediaItem] {
        items.filter { selectedItemIDs.contains($0.id) }
    }
    
    public func refresh() async {
        if let directory = currentDirectory {
            await loadDirectory(directory)
        }
    }
}

// MARK: - Browser View

public struct Browser: View {
    @StateObject public var viewModel: BrowserViewModel
    @State private var isTargeted = false
    
    public init(viewModel: BrowserViewModel = BrowserViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            BrowserToolbar(viewModel: viewModel)
                .frame(height: 50)
            
            if viewModel.isLoading {
                ProgressView(value: viewModel.importProgress)
                    .progressViewStyle(.linear)
                    .padding()
            }
            
            ScrollView {
                switch viewModel.viewMode {
                case .list:
                    ListView(viewModel: viewModel)
                case .grid:
                    GridView(viewModel: viewModel)
                case .filmstrip:
                    FilmstripView(viewModel: viewModel)
                }
            }
            .background(isTargeted ? Color.blue.opacity(0.1) : Color.clear)
            .border(isTargeted ? Color.blue : Color.clear, width: 2)
            .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
                handleDrop(providers: providers)
            }
        }
        .background(Color.black.opacity(0.9))
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        var handledCount = 0
        
        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                provider.loadObject(ofClass: URL.self) { url, error in
                    guard let url = url else { return }
                    Task { @MainActor in
                        await self.importFile(url)
                        handledCount += 1
                    }
                }
            }
        }
        
        return handledCount > 0
    }
    
    private func importFile(_ url: URL) async {
        let mediaType = determineMediaType(url)
        
        let item = BrowserViewModel.MediaItem(
            url: url,
            name: url.lastPathComponent,
            type: mediaType
        )
        
        viewModel.items.append(item)
    }
    
    private func determineMediaType(_ url: URL) -> BrowserViewModel.MediaType {
        let ext = url.pathExtension.lowercased()
        let videoExtensions = ["mp4", "mov", "avi", "mkv", "webm", "m4v"]
        let audioExtensions = ["mp3", "wav", "aac", "m4a", "flac"]
        
        if videoExtensions.contains(ext) { return .video }
        if audioExtensions.contains(ext) { return .audio }
        return .image
    }
}

// MARK: - Browser Toolbar

public struct BrowserToolbar: View {
    @ObservedObject public var viewModel: BrowserViewModel
    
    public var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
            }
            .padding(6)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(6)
            .frame(width: 200)
            
            Picker("Filter", selection: $viewModel.filterType) {
                Text("All").tag(nil as BrowserViewModel.MediaType?)
                ForEach(BrowserViewModel.MediaType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type as BrowserViewModel.MediaType?)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 100)
            
            Picker("Sort", selection: $viewModel.sortOrder) {
                ForEach(BrowserViewModel.SortOrder.allCases, id: \.self) { order in
                    Text(order.rawValue).tag(order)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 100)
            
            Spacer()
            
            Picker("View", selection: $viewModel.viewMode) {
                ForEach(BrowserViewModel.ViewMode.allCases, id: \.self) { mode in
                    Image(systemName: iconForMode(mode)).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 120)
            
            Button(action: { Task { await viewModel.refresh() } }) {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .background(Color.gray.opacity(0.15))
    }
    
    private func iconForMode(_ mode: BrowserViewModel.ViewMode) -> String {
        switch mode {
        case .list: return "list.bullet"
        case .grid: return "square.grid.2x2"
        case .filmstrip: return "film"
        }
    }
}

// MARK: - List View

public struct ListView: View {
    @ObservedObject public var viewModel: BrowserViewModel
    
    public var body: some View {
        LazyVStack(alignment: .leading, spacing: 2) {
            HeaderRow()
            
            ForEach(viewModel.filteredItems) { item in
                ListItemRow(item: item, viewModel: viewModel)
                    .background(viewModel.selectedItemIDs.contains(item.id) ? Color.blue.opacity(0.3) : Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if NSEvent.modifierFlags.contains(.command) {
                            viewModel.toggleSelection(item.id)
                        } else {
                            viewModel.selectItem(item.id)
                        }
                    }
                    .contextMenu {
                        Button("Import to Timeline") {
                            // Handle import
                        }
                        Button("Preview") {
                            // Handle preview
                        }
                        Divider()
                        Button("Show in Finder") {
                            NSWorkspace.shared.activateFileViewerSelecting([item.url])
                        }
                        Divider()
                        Button("Delete") {
                            viewModel.deleteSelected()
                        }
                    }
                    .onDrag {
                        viewModel.draggedItems = [item]
                        return NSItemProvider(object: item.url as NSURL)
                    }
            }
        }
        .padding()
    }
}

public struct HeaderRow: View {
    public var body: some View {
        HStack {
            Text("Name")
                .frame(width: 200, alignment: .leading)
            Text("Duration")
                .frame(width: 80, alignment: .leading)
            Text("Type")
                .frame(width: 60, alignment: .leading)
            Text("Size")
                .frame(width: 80, alignment: .leading)
            Text("Date")
                .frame(width: 100, alignment: .leading)
        }
        .font(.caption.bold())
        .foregroundColor(.gray)
        .padding(.vertical, 4)
    }
}

public struct ListItemRow: View {
    let item: BrowserViewModel.MediaItem
    @ObservedObject var viewModel: BrowserViewModel
    
    public var body: some View {
        HStack {
            HStack(spacing: 8) {
                if let thumbnail = item.thumbnail,
                   let image = NSImage(data: thumbnail) {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 30)
                        .cornerRadius(3)
                } else {
                    placeholderIcon
                        .frame(width: 40, height: 30)
                }
                
                Text(item.name)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .frame(width: 200, alignment: .leading)
            
            Text(item.formattedDuration)
                .font(.caption.monospacedDigit())
                .frame(width: 80, alignment: .leading)
            
            Text(item.type.rawValue)
                .font(.caption)
                .frame(width: 60, alignment: .leading)
            
            Text(item.formattedFileSize)
                .font(.caption)
                .frame(width: 80, alignment: .leading)
            
            Text(item.formattedDate)
                .font(.caption)
                .frame(width: 100, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
    
    private var placeholderIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.3))
            
            Image(systemName: iconName)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
    }
    
    private var iconName: String {
        switch item.type {
        case .video: return "video.fill"
        case .audio: return "waveform"
        case .image: return "photo.fill"
        }
    }
}

// MARK: - Grid View

public struct GridView: View {
    @ObservedObject public var viewModel: BrowserViewModel
    
    public var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160, maximum: 200))], spacing: 16) {
            ForEach(viewModel.filteredItems) { item in
                GridItemView(item: item, viewModel: viewModel)
                    .onTapGesture {
                        if NSEvent.modifierFlags.contains(.command) {
                            viewModel.toggleSelection(item.id)
                        } else {
                            viewModel.selectItem(item.id)
                        }
                    }
                    .contextMenu {
                        Button("Import to Timeline") { }
                        Button("Preview") { }
                        Divider()
                        Button("Show in Finder") {
                            NSWorkspace.shared.activateFileViewerSelecting([item.url])
                        }
                    }
                    .onDrag {
                        viewModel.draggedItems = [item]
                        return NSItemProvider(object: item.url as NSURL)
                    }
            }
        }
        .padding()
    }
}

public struct GridItemView: View {
    let item: BrowserViewModel.MediaItem
    @ObservedObject var viewModel: BrowserViewModel
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .bottomTrailing) {
                if let thumbnail = item.thumbnail,
                   let image = NSImage(data: thumbnail) {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                } else {
                    placeholderView
                }
                
                if item.type == .video {
                    Text(item.formattedDuration)
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(3)
                        .padding(4)
                }
                
                if viewModel.selectedItemIDs.contains(item.id) {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.blue, lineWidth: 3)
                }
            }
            .frame(height: 100)
            .cornerRadius(4)
            
            Text(item.name)
                .font(.caption)
                .lineLimit(2)
                .truncationMode(.middle)
            
            HStack {
                Image(systemName: iconName)
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(item.formattedFileSize)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 160)
        .padding(8)
        .background(viewModel.selectedItemIDs.contains(item.id) ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
    
    private var placeholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
            Image(systemName: iconName)
                .font(.system(size: 32))
                .foregroundColor(.gray)
        }
    }
    
    private var iconName: String {
        switch item.type {
        case .video: return "video.fill"
        case .audio: return "waveform"
        case .image: return "photo.fill"
        }
    }
}

// MARK: - Filmstrip View

public struct FilmstripView: View {
    @ObservedObject public var viewModel: BrowserViewModel
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            LazyHStack(spacing: 8) {
                ForEach(viewModel.filteredItems) { item in
                    FilmstripItemView(item: item, viewModel: viewModel)
                        .onTapGesture {
                            viewModel.selectItem(item.id)
                        }
                        .onDrag {
                            viewModel.draggedItems = [item]
                            return NSItemProvider(object: item.url as NSURL)
                        }
                }
            }
            .padding()
        }
    }
}

public struct FilmstripItemView: View {
    let item: BrowserViewModel.MediaItem
    @ObservedObject var viewModel: BrowserViewModel
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .bottomTrailing) {
                if let thumbnail = item.thumbnail,
                   let image = NSImage(data: thumbnail) {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                        Image(systemName: "video.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                
                Text(item.formattedDuration)
                    .font(.caption2.bold())
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(3)
                    .padding(4)
            }
            .frame(width: 200, height: 112)
            .cornerRadius(4)
            
            Text(item.name)
                .font(.caption)
                .lineLimit(1)
                .frame(width: 200, alignment: .leading)
        }
        .padding(8)
        .background(viewModel.selectedItemIDs.contains(item.id) ? Color.blue.opacity(0.3) : Color.clear)
        .cornerRadius(8)
    }
}

// MARK: - Preview

#Preview {
    Browser()
        .frame(width: 800, height: 600)
}
