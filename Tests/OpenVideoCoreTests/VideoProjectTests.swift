import XCTest
@testable import OpenVideoCore

final class VideoProjectTests: XCTestCase {
    
    func testVideoProjectInitialization() {
        let resolution = CGSize(width: 1920, height: 1080)
        let project = VideoProject(
            name: "Test Project",
            resolution: resolution,
            frameRate: 30.0,
            duration: 120.0
        )
        
        XCTAssertEqual(project.name, "Test Project")
        XCTAssertEqual(project.resolution.width, 1920)
        XCTAssertEqual(project.resolution.height, 1080)
        XCTAssertEqual(project.frameRate, 30.0)
        XCTAssertEqual(project.duration, 120.0)
    }
    
    func testVideoProjectWithDifferentResolutions() {
        let resolutions = [
            ("4K UHD", CGSize(width: 3840, height: 2160), 60.0),
            ("1080p", CGSize(width: 1920, height: 1080), 30.0),
            ("720p", CGSize(width: 1280, height: 720), 24.0),
            ("SD", CGSize(width: 720, height: 480), 29.97)
        ]
        
        for (name, resolution, frameRate) in resolutions {
            let project = VideoProject(
                name: name,
                resolution: resolution,
                frameRate: frameRate,
                duration: 60.0
            )
            
            XCTAssertEqual(project.resolution, resolution)
            XCTAssertEqual(project.frameRate, frameRate)
        }
    }
    
    func testVideoProjectDurationValidation() {
        let project = VideoProject(
            name: "Duration Test",
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0,
            duration: 0
        )
        
        XCTAssertGreaterThanOrEqual(project.duration, 0)
    }
}
