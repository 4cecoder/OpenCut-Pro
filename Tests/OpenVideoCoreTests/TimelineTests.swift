import XCTest
@testable import OpenVideoCore

final class TimelineTests: XCTestCase {
    
    var timeline: Timeline!
    
    override func setUp() {
        super.setUp()
        timeline = Timeline()
    }
    
    override func tearDown() {
        timeline = nil
        super.tearDown()
    }
    
    func testTimelineInitialization() {
        XCTAssertNotNil(timeline)
        XCTAssertTrue(timeline.clips.isEmpty)
        XCTAssertEqual(timeline.currentTime, 0)
    }
    
    func testAddClip() {
        let clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            duration: 60.0,
            startTime: 0.0,
            endTime: 60.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        timeline.addClip(clip)
        
        XCTAssertEqual(timeline.clips.count, 1)
        XCTAssertEqual(timeline.clips.first?.id, clip.id)
    }
    
    func testRemoveClip() {
        let clip1 = VideoClip(
            id: UUID(),
            filePath: "/path/to/video1.mp4",
            duration: 60.0,
            startTime: 0.0,
            endTime: 60.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        let clip2 = VideoClip(
            id: UUID(),
            filePath: "/path/to/video2.mp4",
            duration: 60.0,
            startTime: 60.0,
            endTime: 120.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        timeline.addClip(clip1)
        timeline.addClip(clip2)
        timeline.removeClip(at: 0)
        
        XCTAssertEqual(timeline.clips.count, 1)
        XCTAssertEqual(timeline.clips.first?.id, clip2.id)
    }
    
    func testGetClipAtTime() {
        let clip1 = VideoClip(
            id: UUID(),
            filePath: "/path/to/video1.mp4",
            duration: 60.0,
            startTime: 0.0,
            endTime: 60.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        let clip2 = VideoClip(
            id: UUID(),
            filePath: "/path/to/video2.mp4",
            duration: 60.0,
            startTime: 60.0,
            endTime: 120.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        timeline.addClip(clip1)
        timeline.addClip(clip2)
        
        let foundClip = timeline.getClip(at: 30.0)
        XCTAssertEqual(foundClip?.id, clip1.id)
        
        let foundClip2 = timeline.getClip(at: 90.0)
        XCTAssertEqual(foundClip2?.id, clip2.id)
        
        let notFoundClip = timeline.getClip(at: 150.0)
        XCTAssertNil(notFoundClip)
    }
    
    func testReorderClips() {
        let clip1 = VideoClip(
            id: UUID(),
            filePath: "/path/to/video1.mp4",
            duration: 60.0,
            startTime: 0.0,
            endTime: 60.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        let clip2 = VideoClip(
            id: UUID(),
            filePath: "/path/to/video2.mp4",
            duration: 60.0,
            startTime: 60.0,
            endTime: 120.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        timeline.addClip(clip1)
        timeline.addClip(clip2)
        
        timeline.reorderClip(from: 0, to: 1)
        
        XCTAssertEqual(timeline.clips[0].id, clip2.id)
        XCTAssertEqual(timeline.clips[1].id, clip1.id)
    }
    
    func testTotalDuration() {
        let clip1 = VideoClip(
            id: UUID(),
            filePath: "/path/to/video1.mp4",
            duration: 60.0,
            startTime: 0.0,
            endTime: 60.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        let clip2 = VideoClip(
            id: UUID(),
            filePath: "/path/to/video2.mp4",
            duration: 30.0,
            startTime: 60.0,
            endTime: 90.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        timeline.addClip(clip1)
        timeline.addClip(clip2)
        
        XCTAssertEqual(timeline.totalDuration, 90.0)
    }
}
