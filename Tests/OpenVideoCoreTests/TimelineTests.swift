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
        XCTAssertTrue(timeline.videoClips.isEmpty)
        XCTAssertTrue(timeline.audioClips.isEmpty)
        XCTAssertEqual(timeline.currentTime, 0)
    }
    
    func testAddVideoClip() {
        let clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        timeline.addVideoClip(clip)
        
        XCTAssertEqual(timeline.videoClips.count, 1)
        XCTAssertEqual(timeline.videoClips.first?.id, clip.id)
    }
    
    func testRemoveVideoClip() {
        let clip1 = VideoClip(
            id: UUID(),
            filePath: "/path/to/video1.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        let clip2 = VideoClip(
            id: UUID(),
            filePath: "/path/to/video2.mp4",
            sourceDuration: 60.0,
            startTime: 60.0,
            endTime: 120.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        timeline.addVideoClip(clip1)
        timeline.addVideoClip(clip2)
        timeline.removeVideoClip(at: 0)
        
        XCTAssertEqual(timeline.videoClips.count, 1)
        XCTAssertEqual(timeline.videoClips.first?.id, clip2.id)
    }
    
    func testGetVideoClipAtTime() {
        let clip1 = VideoClip(
            id: UUID(),
            filePath: "/path/to/video1.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        let clip2 = VideoClip(
            id: UUID(),
            filePath: "/path/to/video2.mp4",
            sourceDuration: 60.0,
            startTime: 60.0,
            endTime: 120.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        timeline.addVideoClip(clip1)
        timeline.addVideoClip(clip2)
        
        let foundClip = timeline.getVideoClip(at: 30.0)
        XCTAssertEqual(foundClip?.id, clip1.id)
        
        let foundClip2 = timeline.getVideoClip(at: 90.0)
        XCTAssertEqual(foundClip2?.id, clip2.id)
        
        let notFoundClip = timeline.getVideoClip(at: 150.0)
        XCTAssertNil(notFoundClip)
    }
    
    func testReorderVideoClips() {
        let clip1 = VideoClip(
            id: UUID(),
            filePath: "/path/to/video1.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        let clip2 = VideoClip(
            id: UUID(),
            filePath: "/path/to/video2.mp4",
            sourceDuration: 60.0,
            startTime: 60.0,
            endTime: 120.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        timeline.addVideoClip(clip1)
        timeline.addVideoClip(clip2)
        
        timeline.reorderVideoClip(from: 0, to: 1)
        
        XCTAssertEqual(timeline.videoClips[0].id, clip2.id)
        XCTAssertEqual(timeline.videoClips[1].id, clip1.id)
    }
    
    func testTotalDuration() {
        let clip1 = VideoClip(
            id: UUID(),
            filePath: "/path/to/video1.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        let clip2 = VideoClip(
            id: UUID(),
            filePath: "/path/to/video2.mp4",
            sourceDuration: 30.0,
            startTime: 60.0,
            endTime: 90.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        timeline.addVideoClip(clip1)
        timeline.addVideoClip(clip2)
        
        XCTAssertEqual(timeline.totalDuration, 90.0)
    }
    
    func testAddAudioClip() {
        let clip = AudioClip(
            id: UUID(),
            filePath: "/path/to/audio.mp3",
            sourceDuration: 180.0,
            startTime: 0.0,
            endTime: 180.0,
            volume: 0.8
        )
        
        timeline.addAudioClip(clip)
        
        XCTAssertEqual(timeline.audioClips.count, 1)
        XCTAssertEqual(timeline.audioClips.first?.id, clip.id)
    }
    
    func testRemoveAudioClip() {
        let clip1 = AudioClip(
            id: UUID(),
            filePath: "/path/to/audio1.mp3",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0
        )
        let clip2 = AudioClip(
            id: UUID(),
            filePath: "/path/to/audio2.mp3",
            sourceDuration: 60.0,
            startTime: 60.0,
            endTime: 120.0
        )
        
        timeline.addAudioClip(clip1)
        timeline.addAudioClip(clip2)
        timeline.removeAudioClip(at: 0)
        
        XCTAssertEqual(timeline.audioClips.count, 1)
        XCTAssertEqual(timeline.audioClips.first?.id, clip2.id)
    }
    
    func testGetAudioClipsAtTime() {
        let clip1 = AudioClip(
            id: UUID(),
            filePath: "/path/to/audio1.mp3",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0
        )
        let clip2 = AudioClip(
            id: UUID(),
            filePath: "/path/to/audio2.mp3",
            sourceDuration: 60.0,
            startTime: 30.0,
            endTime: 90.0
        )
        
        timeline.addAudioClip(clip1)
        timeline.addAudioClip(clip2)
        
        let clipsAt45 = timeline.getAudioClips(at: 45.0)
        XCTAssertEqual(clipsAt45.count, 2)
        
        let clipsAt75 = timeline.getAudioClips(at: 75.0)
        XCTAssertEqual(clipsAt75.count, 1)
        XCTAssertEqual(clipsAt75.first?.id, clip2.id)
    }
}
