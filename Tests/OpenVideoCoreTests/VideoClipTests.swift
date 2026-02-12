import XCTest
@testable import OpenVideoCore

final class VideoClipTests: XCTestCase {
    
    func testVideoClipInitialization() {
        let clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        XCTAssertEqual(clip.filePath, "/path/to/video.mp4")
        XCTAssertEqual(clip.duration, 60.0)
        XCTAssertEqual(clip.sourceDuration, 60.0)
        XCTAssertEqual(clip.startTime, 0.0)
        XCTAssertEqual(clip.endTime, 60.0)
        XCTAssertEqual(clip.resolution?.width, 1920)
        XCTAssertEqual(clip.frameRate, 30.0)
    }
    
    func testVideoClipTimingValidation() {
        let clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            sourceDuration: 60.0,
            startTime: 10.0,
            endTime: 40.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        XCTAssertTrue(clip.validateTiming())
    }
    
    func testVideoClipInvalidTiming() {
        let clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            sourceDuration: 30.0,
            startTime: 40.0,
            endTime: 10.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        XCTAssertFalse(clip.validateTiming())
    }
    
    func testVideoClipTrimming() {
        var clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        clip.trim(start: 10.0, end: 50.0)
        
        XCTAssertEqual(clip.startTime, 10.0)
        XCTAssertEqual(clip.endTime, 50.0)
        XCTAssertEqual(clip.duration, 40.0)
    }
    
    func testVideoClipTrimmingValidation() {
        var clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        // Try to trim beyond bounds
        let result = clip.trim(start: -5.0, end: 70.0)
        
        XCTAssertFalse(result)
        XCTAssertEqual(clip.startTime, 0.0)
        XCTAssertEqual(clip.endTime, 60.0)
    }
    
    func testVideoClipSplit() {
        let clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        let (first, second) = clip.split(at: 30.0)
        
        XCTAssertEqual(first?.endTime, 30.0)
        XCTAssertEqual(second?.startTime, 30.0)
        XCTAssertEqual(first?.duration, 30.0)
        XCTAssertEqual(second?.duration, 30.0)
    }
    
    func testVideoClipSplitAtInvalidPosition() {
        let clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        let (first, second) = clip.split(at: 70.0)
        
        XCTAssertNil(first)
        XCTAssertNil(second)
    }
    
    func testVideoClipDefaultInitialization() {
        let clip = VideoClip(
            filePath: "/path/to/video.mp4",
            sourceDuration: 120.0
        )
        
        XCTAssertEqual(clip.filePath, "/path/to/video.mp4")
        XCTAssertEqual(clip.sourceDuration, 120.0)
        XCTAssertEqual(clip.startTime, 0.0)
        XCTAssertEqual(clip.endTime, 120.0)
        XCTAssertTrue(clip.isEnabled)
        XCTAssertTrue(clip.effects.isEmpty)
        XCTAssertTrue(clip.transitions.isEmpty)
    }
    
    func testVideoClipEffects() {
        var clip = VideoClip(
            filePath: "/path/to/video.mp4",
            sourceDuration: 60.0
        )
        
        let effect = Effect(
            name: "Test Effect",
            type: .blur,
            startTime: 0.0,
            duration: 5.0
        )
        
        clip.effects.append(effect)
        
        XCTAssertEqual(clip.effects.count, 1)
        XCTAssertEqual(clip.effects.first?.name, "Test Effect")
    }
    
    func testVideoClipTransitions() {
        var clip = VideoClip(
            filePath: "/path/to/video.mp4",
            sourceDuration: 60.0
        )
        
        let transition = Transition(
            name: "Fade",
            type: .fade,
            duration: 1.0
        )
        
        clip.transitions.append(transition)
        
        XCTAssertEqual(clip.transitions.count, 1)
        XCTAssertEqual(clip.transitions.first?.type, .fade)
    }
}
