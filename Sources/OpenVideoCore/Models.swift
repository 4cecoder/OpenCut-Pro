import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif

// MARK: - Core Models

public struct VideoProject: Codable, Identifiable {
    public let id: UUID
    public var name: String
    public var resolution: VideoSize
    public var frameRate: Double
    public var duration: TimeInterval
    public var createdAt: Date
    public var modifiedAt: Date
    public var timeline: Timeline
    public var exportSettings: ExportSettings
    
    public init(id: UUID = UUID(), name: String, resolution: VideoSize, frameRate: Double, duration: TimeInterval = 0) {
        self.id = id
        self.name = name
        self.resolution = resolution
        self.frameRate = frameRate
        self.duration = duration
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.timeline = Timeline()
        self.exportSettings = ExportSettings()
    }
}

public struct VideoSize: Codable {
    public var width: Double
    public var height: Double
    
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
}

public struct ExportSettings: Codable {
    public var format: ExportFormat
    public var quality: ExportQuality
    public var codec: VideoCodec
    public var includeAudio: Bool
    public var audioBitrate: Int
    public var videoBitrate: Int
    
    public init(format: ExportFormat = .mp4, quality: ExportQuality = .high, codec: VideoCodec = .h264, includeAudio: Bool = true, audioBitrate: Int = 128000, videoBitrate: Int = 5000000) {
        self.format = format
        self.quality = quality
        self.codec = codec
        self.includeAudio = includeAudio
        self.audioBitrate = audioBitrate
        self.videoBitrate = videoBitrate
    }
}

public enum ExportFormat: String, Codable, CaseIterable {
    case mp4 = "MP4"
    case mov = "MOV"
    case avi = "AVI"
    case mkv = "MKV"
    case webm = "WebM"
}

public enum ExportQuality: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case ultra = "Ultra"
    case lossless = "Lossless"
}

public enum VideoCodec: String, Codable, CaseIterable {
    case h264 = "H.264"
    case h265 = "H.265/HEVC"
    case prores = "ProRes"
    case vp9 = "VP9"
    case av1 = "AV1"
}

// MARK: - Video Clip Model

public struct VideoClip: Identifiable, Codable {
    public let id: UUID
    public var filePath: String
    public var sourceDuration: TimeInterval
    public var startTime: TimeInterval
    public var endTime: TimeInterval
    public var resolution: VideoSize?
    public var frameRate: Double?
    public var effects: [Effect]
    public var transitions: [Transition]
    public var isEnabled: Bool
    
    public var duration: TimeInterval {
        return endTime - startTime
    }
    
    public init(id: UUID = UUID(), filePath: String, sourceDuration: TimeInterval, startTime: TimeInterval = 0, endTime: TimeInterval? = nil, resolution: VideoSize? = nil, frameRate: Double? = nil) {
        self.id = id
        self.filePath = filePath
        self.sourceDuration = sourceDuration
        self.startTime = startTime
        self.endTime = endTime ?? sourceDuration
        self.resolution = resolution
        self.frameRate = frameRate
        self.effects = []
        self.transitions = []
        self.isEnabled = true
    }
    
    public func validateTiming() -> Bool {
        return startTime >= 0 && endTime <= sourceDuration && startTime < endTime
    }
    
    @discardableResult
    public mutating func trim(start: TimeInterval, end: TimeInterval) -> Bool {
        guard start >= 0 && end <= sourceDuration && start < end else {
            return false
        }
        self.startTime = start
        self.endTime = end
        return true
    }
    
    public func split(at time: TimeInterval) -> (VideoClip?, VideoClip?) {
        guard time > startTime && time < endTime else {
            return (nil, nil)
        }
        
        var firstClip = self
        var secondClip = self
        
        firstClip.endTime = time
        secondClip.startTime = time
        
        return (firstClip, secondClip)
    }
}

// MARK: - Audio Clip Model

public struct AudioClip: Identifiable, Codable {
    public let id: UUID
    public var filePath: String
    public var sourceDuration: TimeInterval
    public var startTime: TimeInterval
    public var endTime: TimeInterval
    public var volume: Float
    public var fadeIn: TimeInterval
    public var fadeOut: TimeInterval
    public var isEnabled: Bool
    
    public var duration: TimeInterval {
        return endTime - startTime
    }
    
    public init(id: UUID = UUID(), filePath: String, sourceDuration: TimeInterval, startTime: TimeInterval = 0, endTime: TimeInterval? = nil, volume: Float = 1.0, fadeIn: TimeInterval = 0, fadeOut: TimeInterval = 0) {
        self.id = id
        self.filePath = filePath
        self.sourceDuration = sourceDuration
        self.startTime = startTime
        self.endTime = endTime ?? sourceDuration
        self.volume = volume
        self.fadeIn = fadeIn
        self.fadeOut = fadeOut
        self.isEnabled = true
    }
}

// MARK: - Timeline Model

public struct Timeline: Codable {
    public var videoClips: [VideoClip]
    public var audioClips: [AudioClip]
    public var currentTime: TimeInterval
    public var totalDuration: TimeInterval
    public var isPlaying: Bool
    public var playbackRate: Double
    
    public init() {
        self.videoClips = []
        self.audioClips = []
        self.currentTime = 0
        self.totalDuration = 0
        self.isPlaying = false
        self.playbackRate = 1.0
    }
    
    public mutating func addVideoClip(_ clip: VideoClip) {
        videoClips.append(clip)
        recalculateTotalDuration()
    }
    
    public mutating func removeVideoClip(at index: Int) {
        guard index >= 0 && index < videoClips.count else { return }
        videoClips.remove(at: index)
        recalculateTotalDuration()
    }
    
    public mutating func reorderVideoClip(from fromIndex: Int, to toIndex: Int) {
        guard fromIndex >= 0 && fromIndex < videoClips.count,
              toIndex >= 0 && toIndex < videoClips.count else { return }
        let clip = videoClips.remove(at: fromIndex)
        videoClips.insert(clip, at: toIndex)
    }
    
    public func getVideoClip(at time: TimeInterval) -> VideoClip? {
        return videoClips.first { $0.isEnabled && $0.startTime <= time && time <= $0.endTime }
    }
    
    public mutating func addAudioClip(_ clip: AudioClip) {
        audioClips.append(clip)
    }
    
    public mutating func removeAudioClip(at index: Int) {
        guard index >= 0 && index < audioClips.count else { return }
        audioClips.remove(at: index)
    }
    
    public func getAudioClips(at time: TimeInterval) -> [AudioClip] {
        return audioClips.filter { $0.isEnabled && $0.startTime <= time && time <= $0.endTime }
    }
    
    private mutating func recalculateTotalDuration() {
        totalDuration = videoClips.map { $0.endTime }.max() ?? 0
    }
}

// MARK: - Effects and Transitions

public struct Effect: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var type: EffectType
    public var parameters: [String: Double]
    public var startTime: TimeInterval
    public var duration: TimeInterval
    public var intensity: Double
    
    public init(id: UUID = UUID(), name: String, type: EffectType, parameters: [String: Double] = [:], startTime: TimeInterval, duration: TimeInterval, intensity: Double = 1.0) {
        self.id = id
        self.name = name
        self.type = type
        self.parameters = parameters
        self.startTime = startTime
        self.duration = duration
        self.intensity = intensity
    }
}

public enum EffectType: String, Codable, CaseIterable {
    case colorCorrection = "Color Correction"
    case blur = "Blur"
    case sharpen = "Sharpen"
    case noise = "Noise Reduction"
    case stabilization = "Stabilization"
    case chromaKey = "Chroma Key"
    case lut = "LUT"
    case custom = "Custom"
}

public struct Transition: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var type: TransitionType
    public var duration: TimeInterval
    public var parameters: [String: Double]
    
    public init(id: UUID = UUID(), name: String, type: TransitionType, duration: TimeInterval, parameters: [String: Double] = [:]) {
        self.id = id
        self.name = name
        self.type = type
        self.duration = duration
        self.parameters = parameters
    }
}

public enum TransitionType: String, Codable, CaseIterable {
    case dissolve = "Dissolve"
    case fade = "Fade"
    case wipe = "Wipe"
    case slide = "Slide"
    case zoom = "Zoom"
    case spin = "Spin"
    case crossfade = "Crossfade"
}
