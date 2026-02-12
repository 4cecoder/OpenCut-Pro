import SwiftUI
import Combine

// MARK: - Viewer View Model

@MainActor
public final class ViewerViewModel: ObservableObject {
    @Published public var currentFrame: CGImage?
    @Published public var isPlaying = false
    @Published public var currentTime: TimeInterval = 0
    @Published public var totalDuration: TimeInterval = 0
    @Published public var resolution: CGSize = CGSize(width: 1920, height: 1080)
    @Published public var frameRate: Double = 30.0
    @Published public var zoomLevel: Double = 1.0
    @Published public var showSafeAreas = false
    @Published public var showOverlayInfo = true
    @Published public var quality: ViewerQuality = .high
    @Published public var isLoading = false
    @Published public var playbackRate: Double = 1.0
    @Published public var loopPlayback = false
    @Published public var isFullscreen = false
    
    public enum ViewerQuality: String, CaseIterable {
        case draft = "Draft"
        case medium = "Medium"
        case high = "High"
        case best = "Best"
        
        public var scaleFactor: Double {
            switch self {
            case .draft: return 0.25
            case .medium: return 0.5
            case .high: return 1.0
            case .best: return 1.5
            }
        }
    }
    
    private var playbackTimer: Timer?
    private var frameCache: [TimeInterval: CGImage] = [:]
    private let maxCacheSize = 30
    private var cancellables = Set<AnyCancellable>()
    
    public init() {}
    
    public func loadFrame(at time: TimeInterval) async {
        guard !isLoading else { return }
        
        if let cachedFrame = frameCache[time] {
            currentFrame = cachedFrame
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        await Task.sleep(UInt64(0.01 * 1_000_000_000))
        
        let frame = await generatePlaceholderFrame()
        
        if frameCache.count >= maxCacheSize {
            frameCache.removeValue(forKey: frameCache.keys.first!)
        }
        frameCache[time] = frame
        
        currentFrame = frame
    }
    
    private func generatePlaceholderFrame() async -> CGImage {
        let width = Int(resolution.width * quality.scaleFactor)
        let height = Int(resolution.height * quality.scaleFactor)
        
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        guard let ctx = context else {
            return createEmptyCGImage()!
        }
        
        ctx.setFillColor(CGColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0))
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        
        ctx.setStrokeColor(CGColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0))
        ctx.setLineWidth(2.0)
        
        let gridSize = 50
        for x in stride(from: 0, to: width, by: gridSize) {
            ctx.move(to: CGPoint(x: x, y: 0))
            ctx.addLine(to: CGPoint(x: x, y: height))
        }
        for y in stride(from: 0, to: height, by: gridSize) {
            ctx.move(to: CGPoint(x: 0, y: y))
            ctx.addLine(to: CGPoint(x: width, y: y))
        }
        ctx.strokePath()
        
        let centerX = width / 2
        let centerY = height / 2
        let crossSize = min(width, height) / 4
        
        ctx.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5))
        ctx.setLineWidth(1.0)
        
        ctx.move(to: CGPoint(x: centerX - crossSize, y: centerY))
        ctx.addLine(to: CGPoint(x: centerX + crossSize, y: centerY))
        ctx.move(to: CGPoint(x: centerX, y: centerY - crossSize))
        ctx.addLine(to: CGPoint(x: centerX, y: centerY + crossSize))
        ctx.strokePath()
        
        ctx.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8))
        let timeString = formatTime(currentTime) as NSString
        timeString.draw(at: CGPoint(x: 20, y: 20), withAttributes: [
            .font: NSFont.systemFont(ofSize: 24),
            .foregroundColor: NSColor.white
        ])
        
        return ctx.makeImage()!
    }
    
    private func createEmptyCGImage() -> CGImage? {
        let width = 1920
        let height = 1080
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        context?.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        context?.fill(CGRect(x: 0, y: 0, width: width, height: height))
        return context?.makeImage()
    }
    
    public func startPlayback() {
        guard !isPlaying else { return }
        isPlaying = true
        
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / (frameRate * playbackRate), repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.advanceFrame()
            }
        }
    }
    
    public func stopPlayback() {
        isPlaying = false
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    private func advanceFrame() {
        let frameDuration = 1.0 / frameRate
        currentTime += frameDuration
        
        if currentTime >= totalDuration {
            if loopPlayback {
                currentTime = 0
            } else {
                currentTime = totalDuration
                stopPlayback()
            }
        }
        
        Task {
            await loadFrame(at: currentTime)
        }
    }
    
    public func seek(to time: TimeInterval) {
        currentTime = max(0, min(time, totalDuration))
        Task {
            await loadFrame(at: currentTime)
        }
    }
    
    public func stepForward() {
        seek(to: currentTime + 1.0 / frameRate)
    }
    
    public func stepBackward() {
        seek(to: currentTime - 1.0 / frameRate)
    }
    
    public func goToStart() {
        seek(to: 0)
    }
    
    public func goToEnd() {
        seek(to: totalDuration)
    }
    
    public func clearCache() {
        frameCache.removeAll()
    }
    
    public func toggleFullscreen() {
        isFullscreen.toggle()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        let frames = Int((time - Double(Int(time))) * frameRate)
        return String(format: "%02d:%02d:%02d:%02d", hours, minutes, seconds, frames)
    }
}

// MARK: - Viewer View

public struct Viewer: View {
    @StateObject public var viewModel: ViewerViewModel
    
    public init(viewModel: ViewerViewModel = ViewerViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                
                if let frame = viewModel.currentFrame {
                    Image(decorative: frame, scale: 1.0)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(viewModel.zoomLevel)
                } else {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading...")
                            .foregroundColor(.gray)
                            .padding(.top)
                    }
                }
                
                if viewModel.showSafeAreas {
                    SafeAreaOverlay()
                }
                
                if viewModel.showOverlayInfo {
                    ViewerOverlay(viewModel: viewModel)
                }
                
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
                }
            }
        }
        .frame(minWidth: 400, minHeight: 225)
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Picker("Quality", selection: $viewModel.quality) {
                    ForEach(ViewerViewModel.ViewerQuality.allCases, id: \.self) { quality in
                        Text(quality.rawValue).tag(quality)
                    }
                }
                .pickerStyle(.menu)
                
                Button(action: { viewModel.showSafeAreas.toggle() }) {
                    Image(systemName: viewModel.showSafeAreas ? "eye.slash" : "eye")
                }
                
                Button(action: { viewModel.toggleFullscreen() }) {
                    Image(systemName: viewModel.isFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                }
            }
        }
        .task {
            await viewModel.loadFrame(at: viewModel.currentTime)
        }
    }
}

// MARK: - Safe Area Overlay

public struct SafeAreaOverlay: View {
    public var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                Rectangle()
                    .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                    .frame(width: width * 0.9, height: height * 0.9)
                
                Rectangle()
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    .frame(width: width * 0.8, height: height * 0.8)
                
                Crosshair()
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            }
        }
    }
}

public struct Crosshair: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let centerX = rect.midX
        let centerY = rect.midY
        let size = min(rect.width, rect.height) / 8
        
        path.move(to: CGPoint(x: centerX - size, y: centerY))
        path.addLine(to: CGPoint(x: centerX + size, y: centerY))
        path.move(to: CGPoint(x: centerX, y: centerY - size))
        path.addLine(to: CGPoint(x: centerX, y: centerY + size))
        
        return path
    }
}

// MARK: - Viewer Overlay

public struct ViewerOverlay: View {
    @ObservedObject public var viewModel: ViewerViewModel
    
    public var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(Int(viewModel.resolution.width))x\(Int(viewModel.resolution.height))")
                        .font(.caption)
                    Text("\(String(format: "%.2f", viewModel.frameRate)) fps")
                        .font(.caption2)
                    Text(formatTime(viewModel.currentTime))
                        .font(.caption.monospacedDigit())
                }
                .foregroundColor(.white)
                .padding(8)
                .background(Color.black.opacity(0.6))
                .cornerRadius(4)
                
                Spacer()
                
                HStack(spacing: 4) {
                    if viewModel.isPlaying {
                        Image(systemName: "play.fill")
                            .foregroundColor(.green)
                    }
                    if viewModel.loopPlayback {
                        Image(systemName: "repeat")
                            .foregroundColor(.blue)
                    }
                }
                .padding(8)
                .background(Color.black.opacity(0.6))
                .cornerRadius(4)
            }
            .padding()
            
            Spacer()
            
            ViewerControls(viewModel: viewModel)
                .padding(.bottom)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        let frames = Int((time - Double(Int(time))) * viewModel.frameRate)
        return String(format: "%02d:%02d:%02d:%02d", hours, minutes, seconds, frames)
    }
}

// MARK: - Viewer Controls

public struct ViewerControls: View {
    @ObservedObject public var viewModel: ViewerViewModel
    
    public var body: some View {
        HStack(spacing: 20) {
            Button(action: { viewModel.goToStart() }) {
                Image(systemName: "backward.end.fill")
                    .font(.title2)
            }
            .buttonStyle(.plain)
            
            Button(action: { viewModel.stepBackward() }) {
                Image(systemName: "backward.frame.fill")
                    .font(.title2)
            }
            .buttonStyle(.plain)
            
            Button(action: togglePlayback) {
                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 44))
            }
            .buttonStyle(.plain)
            
            Button(action: { viewModel.stepForward() }) {
                Image(systemName: "forward.frame.fill")
                    .font(.title2)
            }
            .buttonStyle(.plain)
            
            Button(action: { viewModel.goToEnd() }) {
                Image(systemName: "forward.end.fill")
                    .font(.title2)
            }
            .buttonStyle(.plain)
            
            Divider()
                .frame(height: 30)
            
            Button(action: { viewModel.loopPlayback.toggle() }) {
                Image(systemName: viewModel.loopPlayback ? "repeat.circle.fill" : "repeat")
                    .font(.title2)
                    .foregroundColor(viewModel.loopPlayback ? .blue : .white)
            }
            .buttonStyle(.plain)
            
            VStack(spacing: 2) {
                Text("Rate")
                    .font(.caption2)
                Picker("", selection: $viewModel.playbackRate) {
                    Text("0.25x").tag(0.25)
                    Text("0.5x").tag(0.5)
                    Text("1x").tag(1.0)
                    Text("2x").tag(2.0)
                    Text("4x").tag(4.0)
                }
                .pickerStyle(.menu)
                .frame(width: 80)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.7))
        )
    }
    
    private func togglePlayback() {
        if viewModel.isPlaying {
            viewModel.stopPlayback()
        } else {
            viewModel.startPlayback()
        }
    }
}

// MARK: - Preview

#Preview {
    Viewer()
        .frame(width: 800, height: 450)
}
