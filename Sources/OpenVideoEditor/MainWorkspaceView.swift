import SwiftUI
import OpenVideoCore

// MARK: - Main Workspace View
// Professional multi-page interface inspired by DaVinci Resolve

struct MainWorkspaceView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top Navigation Bar with Page Selector
                NavigationBar()
                    .frame(height: 48)
                
                // Main Content Area - Switch based on current page
                switch appState.currentPage {
                case .media:
                    MediaPage()
                case .cut:
                    CutPage()
                case .edit:
                    EditPage()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .fusion:
                    FusionPage()
                case .color:
                    ColorPage()
                case .fairlight:
                    FairlightPage()
                case .deliver:
                    DeliverPage()
                }
            }
            .background(Color(.sRGB, red: 0.04, green: 0.04, blue: 0.04))
            .ignoresSafeArea()
        }
        .sheet(isPresented: $appState.showNewProjectSheet) {
            ProfessionalNewProjectSheet()
        }
        .sheet(isPresented: $appState.showExportSheet) {
            ProfessionalExportSheet()
        }
        .sheet(isPresented: $appState.showProjectSettings) {
            ProjectSettingsSheet()
        }
    }
}

// MARK: - Navigation Bar

struct NavigationBar: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 0) {
            // Project Info
            HStack(spacing: 12) {
                Image(systemName: "film.stack.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(appState.currentProject?.name ?? "Untitled Project")
                        .font(.system(size: 13, weight: .semibold))
                    
                    HStack(spacing: 4) {
                        if let project = appState.currentProject {
                            Text("\(Int(project.resolution.width))×\(Int(project.resolution.height))")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            
                            Text("•")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            
                            Text("\(String(format: "%.2f", project.frameRate)) fps")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.leading, 16)
            
            Spacer()
            
            // Page Selector (DaVinci Resolve style)
            HStack(spacing: 0) {
                ForEach(WorkspacePage.allCases, id: \.self) { page in
                    PageSelectorButton(
                        page: page,
                        isActive: appState.currentPage == page
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            appState.currentPage = page
                        }
                    }
                }
            }
            .background(Color(.sRGB, red: 0.10, green: 0.10, blue: 0.10))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: "333333"), lineWidth: 1)
            )
            
            Spacer()
            
            // Right: Tools & Collaborators
            HStack(spacing: 16) {
                // Active collaborators
                HStack(spacing: -8) {
                    ForEach(appState.collaborators.prefix(3)) { collaborator in
                        Circle()
                            .fill(collaborator.color)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Text(String(collaborator.name.prefix(1)))
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .border(Color(.sRGB, red: 0.10, green: 0.10, blue: 0.10), width: 2)
                    }
                }
                
                // Share button
                Button(action: { appState.shareProject() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.badge.plus")
                        Text("Share")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Settings
                Button(action: { appState.showProjectSettings = true }) {
                    Image(systemName: "gear")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.trailing, 16)
        }
        .background(Color(.sRGB, red: 0.08, green: 0.08, blue: 0.08))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.black.opacity(0.5)),
            alignment: .bottom
        )
    }
}

struct PageSelectorButton: View {
    let page: WorkspacePage
    let isActive: Bool
    let action: () -> Void
    
    var icon: String {
        switch page {
        case .media: return "film.stack"
        case .cut: return "scissors"
        case .edit: return "timeline.selection"
        case .fusion: return "atom"
        case .color: return "paintpalette"
        case .fairlight: return "waveform"
        case .deliver: return "square.and.arrow.up"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(page.rawValue)
                    .font(.system(size: 10, weight: .medium))
            }
            .frame(width: 70, height: 42)
            .foregroundColor(isActive ? Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21) : Color.gray)
            .background(isActive ? Color(.sRGB, red: 0.05, green: 0.05, blue: 0.05) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Edit Page (Main Editing Interface)

struct EditPage: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top Section: Browser + Viewer + Inspector
                HStack(spacing: 0) {
                    // Left: Media Pool (Browser)
                    if appState.showBrowser {
                        ProfessionalMediaPool()
                            .frame(width: 320)
                            .transition(.move(edge: .leading))
                    }
                    
                    // Center: Viewer with Scopes
                    if appState.showViewer {
                        ProfessionalViewer()
                            .frame(minWidth: 500)
                    }
                    
                    // Right: Inspector Panel
                    if appState.showInspector {
                        ProfessionalInspector()
                            .frame(width: 320)
                            .transition(.move(edge: .trailing))
                    }
                }
                .frame(height: geometry.size.height * 0.55)
                
                // Timeline Section
                if appState.showTimeline {
                    ProfessionalTimeline()
                        .frame(height: geometry.size.height * 0.45)
                        .transition(.move(edge: .bottom))
                }
            }
        }
    }
}

// MARK: - Professional Media Pool

struct ProfessionalMediaPool: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var viewMode: ViewMode = .list
    @State private var selectedSmartBin: SmartBin? = nil
    
    enum ViewMode {
        case list, icon, filmstrip
    }
    
    let smartBins = [
        SmartBin(name: "All Media", icon: "film", count: 156),
        SmartBin(name: "Favorites", icon: "star.fill", count: 23),
        SmartBin(name: "Video", icon: "video.fill", count: 89),
        SmartBin(name: "Audio", icon: "waveform", count: 45),
        SmartBin(name: "Graphics", icon: "photo.fill", count: 22)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Smart Bins
            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Text("Media Pool")
                        .font(.system(size: 14, weight: .semibold))
                    
                    Spacer()
                    
                    // View Mode Toggle
                    HStack(spacing: 4) {
                        ForEach([ViewMode.list, .icon, .filmstrip], id: \.self) { mode in
                            Button(action: { viewMode = mode }) {
                                Image(systemName: iconForMode(mode))
                                    .font(.system(size: 11))
                                    .frame(width: 24, height: 24)
                                    .background(viewMode == mode ? Color(.sRGB, red: 0.16, green: 0.16, blue: 0.16) : Color.clear)
                                    .cornerRadius(4)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .foregroundColor(viewMode == mode ? .white : .gray)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                
                // Smart Bins
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(smartBins) { bin in
                            SmartBinButton(bin: bin, isSelected: selectedSmartBin?.id == bin.id) {
                                selectedSmartBin = bin
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
            }
            .background(Color(.sRGB, red: 0.09, green: 0.09, blue: 0.09))
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                
                TextField("Search by metadata, keywords, or labels...", text: $searchText)
                    .font(.system(size: 12))
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(8)
            .background(Color(.sRGB, red: 0.13, green: 0.13, blue: 0.13))
            .cornerRadius(6)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Media Content
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(0..<20) { index in
                        MediaPoolItem(index: index, viewMode: viewMode)
                    }
                }
                .padding(.horizontal, 8)
            }
            
            // Metadata Panel (Bottom)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Metadata")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button("Edit") {
                    }
                    .font(.system(size: 10))
                    .foregroundColor(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21))
                }
                
                VStack(spacing: 6) {
                    MetadataField(label: "File Name", value: "Scene_001_ProRes.mov")
                    MetadataField(label: "Duration", value: "00:01:23:15")
                    MetadataField(label: "Resolution", value: "3840 × 2160 (4K)")
                    MetadataField(label: "Codec", value: "Apple ProRes 422 HQ")
                    MetadataField(label: "Color Space", value: "Rec. 2020 (HDR)")
                    MetadataField(label: "Frame Rate", value: "59.94 fps")
                    MetadataField(label: "Camera", value: "Sony FX6")
                }
            }
            .padding(12)
            .background(Color(.sRGB, red: 0.10, green: 0.10, blue: 0.10))
            .frame(height: 180)
        }
        .background(Color(.sRGB, red: 0.08, green: 0.08, blue: 0.08))
        .foregroundColor(.white)
    }
    
    func iconForMode(_ mode: ViewMode) -> String {
        switch mode {
        case .list: return "list.bullet"
        case .icon: return "square.grid.2x2"
        case .filmstrip: return "film"
        }
    }
}

struct SmartBin: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let count: Int
}

struct SmartBinButton: View {
    let bin: SmartBin
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: bin.icon)
                    .font(.system(size: 11))
                
                Text(bin.name)
                    .font(.system(size: 11))
                
                Text("(\(bin.count))")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21).opacity(0.2) : Color(.sRGB, red: 0.13, green: 0.13, blue: 0.13))
            .foregroundColor(isSelected ? Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21) : .gray)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MediaPoolItem: View {
    let index: Int
    let viewMode: ProfessionalMediaPool.ViewMode
    @State private var isSelected = false
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            ZStack {
                Rectangle()
                    .fill(Color(.sRGB, red: 0.16, green: 0.16, blue: 0.16))
                    .frame(width: 80, height: 45)
                    .cornerRadius(3)
                
                Image(systemName: "film.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(.sRGB, red: 0.23, green: 0.23, blue: 0.23))
                
                // HDR Badge
                if index % 3 == 0 {
                    Text("HDR")
                        .font(.system(size: 8, weight: .bold))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21))
                        .foregroundColor(.white)
                        .cornerRadius(2)
                        .position(x: 70, y: 8)
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text("Clip_\(String(format: "%03d", index + 1))_Take\(Int.random(in: 1...5))")
                    .font(.system(size: 12, weight: .medium))
                
                HStack(spacing: 8) {
                    Label("00:0\(index % 9 + 1):\(String(format: "%02d", Int.random(in: 10...59)))", systemImage: "clock")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text("4K ProRes")
                        .font(.system(size: 10))
                        .foregroundColor(Color(.sRGB, red: 0.29, green: 0.62, blue: 1.0))
                }
            }
            
            Spacer()
            
            // Rating Stars
            HStack(spacing: 2) {
                ForEach(0..<5) { i in
                    Image(systemName: i < Int.random(in: 3...5) ? "star.fill" : "star")
                        .font(.system(size: 8))
                        .foregroundColor(i < 3 ? Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21) : .gray)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(isSelected ? Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21).opacity(0.15) : (isHovered ? Color(.sRGB, red: 0.12, green: 0.12, blue: 0.12) : Color.clear))
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isSelected ? Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21).opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            isSelected.toggle()
        }
    }
}

struct MetadataField: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 10))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Spacer()
        }
    }
}

// Additional pages will be implemented in the next file

struct MediaPage: View {
    var body: some View {
        Text("Media Page - Import and organize")
            .foregroundColor(.white)
    }
}

struct CutPage: View {
    var body: some View {
        Text("Cut Page - Quick assembly editing")
            .foregroundColor(.white)
    }
}

struct FusionPage: View {
    var body: some View {
        Text("Fusion Page - Visual Effects and Motion Graphics")
            .foregroundColor(.white)
    }
}

struct ColorPage: View {
    var body: some View {
        Text("Color Page - Professional Color Grading")
            .foregroundColor(.white)
    }
}

struct FairlightPage: View {
    var body: some View {
        Text("Fairlight Page - Audio Post-Production")
            .foregroundColor(.white)
    }
}

struct DeliverPage: View {
    var body: some View {
        Text("Deliver Page - Export and Delivery")
            .foregroundColor(.white)
    }
}

extension WorkspacePage: CaseIterable {
    static var allCases: [WorkspacePage] = [.media, .cut, .edit, .fusion, .color, .fairlight, .deliver]
}
