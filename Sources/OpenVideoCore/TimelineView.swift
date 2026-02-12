import SwiftUI
import Combine

// MARK: - Timeline View Model

@MainActor
public final class TimelineViewModel: ObservableObject {
    @Published public var timeline: Timeline
    @Published public var zoomLevel: Double = 1.0
    @Published public var scrollOffset: Double = 0.0
    @Published public var selectedClipID: UUID?
    @Published public var isDragging = false
    @Published public var dragPosition: Double = 0.0
    @Published public var magneticSnapPoints: [Double] = []
    @Published public var showSnapIndicators = false
    
    private var cancellables = Set<AnyCancellable>()
    private var playbackTimer: Timer?
    
    public var pixelsPerSecond: Double {
        return 100.0 * zoomLevel
    }
    
    public init(timeline: Timeline = Timeline()) {
        self.timeline = timeline
        setupBindings()
    }
    
    private func setupBindings() {
        $timeline
            .sink { [weak self] _ in
                self?.updateSnapPoints()
            }
            .store(in: &cancellables)
    }
    
    private func updateSnapPoints() {
        var points: [Double] = [0.0, timeline.totalDuration]
        for clip in timeline.videoClips {
            points.append(clip.startTime)
            points.append(clip.endTime)
        }
        magneticSnapPoints = points.sorted()
    }
    
    public func timeToX(_ time: TimeInterval) -> Double {
        return time * pixelsPerSecond - scrollOffset
    }
    
    public func xToTime(_ x: Double) -> TimeInterval {
        return (x + scrollOffset) / pixelsPerSecond
    }
    
    public func snapToMagneticPoint(_ time: TimeInterval) -> TimeInterval {
        let snapThreshold = 0.5 / zoomLevel
        for point in magneticSnapPoints {
            if abs(time - point) < snapThreshold {
                return point
            }
        }
        return time
    }
    
    public func startPlayback() {
        timeline.isPlaying = true
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.advancePlayback()
            }
        }
    }
    
    public func stopPlayback() {
        timeline.isPlaying = false
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    private func advancePlayback() {
        timeline.currentTime += (1.0 / timeline.playbackRate) / 30.0
        if timeline.currentTime >= timeline.totalDuration {
            timeline.currentTime = timeline.totalDuration
            stopPlayback()
        }
    }
    
    public func seek(to time: TimeInterval) {
        timeline.currentTime = max(0, min(time, timeline.totalDuration))
    }
    
    public func moveClip(_ clipID: UUID, to newStartTime: TimeInterval) {
        guard let index = timeline.videoClips.firstIndex(where: { $0.id == clipID }) else { return }
        var clip = timeline.videoClips[index]
        let duration = clip.duration
        let snappedStart = snapToMagneticPoint(newStartTime)
        clip.startTime = snappedStart
        clip.endTime = snappedStart + duration
        timeline.videoClips[index] = clip
        timeline.recalculateTotalDuration()
    }
}

// MARK: - Timeline View

public struct TimelineView: View {
    @StateObject public var viewModel: TimelineViewModel
    @State private var isHoveringOverClip = false
    
    public init(viewModel: TimelineViewModel = TimelineViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            TimeRulerView(viewModel: viewModel)
                .frame(height: 30)
            
            ScrollView(.horizontal, showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    TimelineBackgroundView()
                        .frame(width: max(800, viewModel.timeToX(viewModel.timeline.totalDuration) + 200), height: 300)
                    
                    ForEach(viewModel.timeline.videoClips) { clip in
                        ClipView(
                            clip: clip,
                            viewModel: viewModel,
                            isSelected: viewModel.selectedClipID == clip.id
                        )
                        .position(
                            x: viewModel.timeToX(clip.startTime + clip.duration / 2),
                            y: 50
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    viewModel.isDragging = true
                                    let newTime = viewModel.xToTime(value.location.x - clip.duration / 2 * viewModel.pixelsPerSecond)
                                    viewModel.dragPosition = newTime
                                    viewModel.showSnapIndicators = true
                                }
                                .onEnded { value in
                                    viewModel.isDragging = false
                                    let newTime = viewModel.xToTime(value.location.x - clip.duration / 2 * viewModel.pixelsPerSecond)
                                    viewModel.moveClip(clip.id, to: newTime)
                                    viewModel.showSnapIndicators = false
                                }
                        )
                        .onTapGesture {
                            viewModel.selectedClipID = clip.id
                        }
                    }
                    
                    PlayheadView(viewModel: viewModel)
                    
                    if viewModel.showSnapIndicators {
                        ForEach(viewModel.magneticSnapPoints, id: \.self) { point in
                            SnapIndicatorView(position: viewModel.timeToX(point))
                        }
                    }
                }
            }
            
            TimelineToolbar(viewModel: viewModel)
                .frame(height: 40)
        }
        .background(Color.black.opacity(0.9))
    }
}

// MARK: - Time Ruler View

public struct TimeRulerView: View {
    @ObservedObject public var viewModel: TimelineViewModel
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                
                let visibleStart = viewModel.xToTime(0)
                let visibleEnd = viewModel.xToTime(geometry.size.width)
                let step = max(1.0, 5.0 / viewModel.zoomLevel)
                
                ForEach(Array(stride(from: visibleStart, through: visibleEnd, by: step)), id: \.self) { time in
                    RulerTick(time: time, viewModel: viewModel)
                }
            }
        }
    }
}

public struct RulerTick: View {
    let time: TimeInterval
    @ObservedObject var viewModel: TimelineViewModel
    
    public var body: some View {
        let x = viewModel.timeToX(time)
        let isMajor = Int(time) % 5 == 0
        
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(Color.white)
                .frame(width: 1, height: isMajor ? 15 : 8)
            
            if isMajor {
                Text(formatTime(time))
                    .font(.caption2)
                    .foregroundColor(.white)
            }
        }
        .position(x: x, y: 15)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let frames = Int((time - Double(Int(time))) * 30)
        return String(format: "%02d:%02d:%02d", minutes, seconds, frames)
    }
}

// MARK: - Clip View

public struct ClipView: View {
    let clip: VideoClip
    @ObservedObject var viewModel: TimelineViewModel
    let isSelected: Bool
    
    public var body: some View {
        let width = clip.duration * viewModel.pixelsPerSecond
        
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(isSelected ? Color.blue.opacity(0.8) : Color.cyan.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? Color.blue : Color.cyan, lineWidth: 2)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(clip.filePath.components(separatedBy: "/").last ?? "Unknown")
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(formatDuration(clip.duration))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(4)
            
            HStack {
                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 4)
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 4)
            }
        }
        .frame(width: max(width, 30), height: 60)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Playhead View

public struct PlayheadView: View {
    @ObservedObject public var viewModel: TimelineViewModel
    
    public var body: some View {
        let x = viewModel.timeToX(viewModel.timeline.currentTime)
        
        ZStack {
            Rectangle()
                .fill(Color.red)
                .frame(width: 2, height: 300)
            
            Triangle()
                .fill(Color.red)
                .frame(width: 12, height: 8)
                .position(x: x, y: 4)
        }
        .position(x: x, y: 150)
        .gesture(
            DragGesture()
                .onChanged { value in
                    let newTime = viewModel.xToTime(value.location.x)
                    viewModel.seek(to: newTime)
                }
        )
    }
}

public struct Triangle: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Snap Indicator View

public struct SnapIndicatorView: View {
    let position: Double
    
    public var body: some View {
        Rectangle()
            .fill(Color.yellow.opacity(0.6))
            .frame(width: 2, height: 300)
            .position(x: position, y: 150)
    }
}

// MARK: - Timeline Background View

public struct TimelineBackgroundView: View {
    public var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.black.opacity(0.95), Color.black.opacity(0.9)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}

// MARK: - Timeline Toolbar

public struct TimelineToolbar: View {
    @ObservedObject public var viewModel: TimelineViewModel
    
    public var body: some View {
        HStack(spacing: 16) {
            Button(action: { viewModel.seek(to: 0) }) {
                Image(systemName: "backward.end.fill")
            }
            
            Button(action: togglePlayback) {
                Image(systemName: viewModel.timeline.isPlaying ? "pause.fill" : "play.fill")
            }
            
            Button(action: { viewModel.seek(to: viewModel.timeline.currentTime - 1.0 / viewModel.timeline.playbackRate) }) {
                Image(systemName: "backward.frame.fill")
            }
            
            Button(action: { viewModel.seek(to: viewModel.timeline.currentTime + 1.0 / viewModel.timeline.playbackRate) }) {
                Image(systemName: "forward.frame.fill")
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("Zoom:")
                    .font(.caption)
                    .foregroundColor(.white)
                Slider(value: $viewModel.zoomLevel, in: 0.1...5.0, step: 0.1)
                    .frame(width: 100)
            }
            
            HStack(spacing: 8) {
                Text("Rate:")
                    .font(.caption)
                    .foregroundColor(.white)
                Picker("", selection: Binding(
                    get: { viewModel.timeline.playbackRate },
                    set: { viewModel.timeline.playbackRate = $0 }
                )) {
                    Text("0.25x").tag(0.25)
                    Text("0.5x").tag(0.5)
                    Text("1x").tag(1.0)
                    Text("2x").tag(2.0)
                    Text("4x").tag(4.0)
                }
                .pickerStyle(.menu)
                .frame(width: 80)
            }
            
            Text(formatTime(viewModel.timeline.currentTime))
                .font(.caption.monospacedDigit())
                .foregroundColor(.white)
                .frame(width: 80)
        }
        .padding(.horizontal)
        .background(Color.gray.opacity(0.2))
    }
    
    private func togglePlayback() {
        if viewModel.timeline.isPlaying {
            viewModel.stopPlayback()
        } else {
            viewModel.startPlayback()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let frames = Int((time - Double(Int(time))) * 30)
        return String(format: "%02d:%02d:%02d", minutes, seconds, frames)
    }
}

// MARK: - Preview

#Preview {
    TimelineView()
        .frame(width: 800, height: 400)
}
