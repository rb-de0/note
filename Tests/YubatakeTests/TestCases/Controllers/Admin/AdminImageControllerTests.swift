@testable import App
import XCTVapor

final class AdminImageControllerTests: ControllerTestCase {
    
    override func buildApp() -> Application {
        let app = try! ApplicationBuilder.buildForAdmin()
        app.register(imageRepository: TestImageFileRepository())
        return app
    }
    
    override func setUp() {
        super.setUp()
        TestImageFileRepository.imageFiles.removeAll()
    }
    
    func testCanViewIndex() throws {
        try app.imageRepository.save(image: "image".data(using: .utf8)!, for: "favicon")
        let image = DataMaker.makeImage(path: "/documents/imgs/favicon", altDescription: "favicon")
        try image.save(on: db).wait()
        try test(.GET, "/admin/images", afterResponse:  { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("hasNotFound")?.bool, false)
        })
    }
    
    func testCanViewCleanButtonWhenHasNotFound() throws {
        let image = DataMaker.makeImage(path: "/documents/imgs/favicon", altDescription: "favicon")
        try image.save(on: db).wait()
        try test(.GET, "/admin/images", afterResponse:  { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("hasNotFound")?.bool, true)
        })
    }
    
    func testCanViewEditView() throws {
        try app.imageRepository.save(image: "image".data(using: .utf8)!, for: "favicon")
        let image = DataMaker.makeImage(path: "/documents/imgs/favicon", altDescription: "favicon")
        try image.save(on: db).wait()
        try test(.GET, "/admin/images/1/edit", afterResponse:  { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("name")?.string, "favicon")
            XCTAssertEqual(view.get("altDescription")?.string, "favicon")
        })
    }
    
    func testCanCleanUp() throws {
        do {
            let image = DataMaker.makeImage(path: "/documents/imgs/favicon", altDescription: "favicon")
            try image.save(on: db).wait()
        }
        do {
            try app.imageRepository.save(image: "image".data(using: .utf8)!, for: "sample")
            let image = DataMaker.makeImage(path: "/documents/imgs/sample", altDescription: "sample")
            try image.save(on: db).wait()
        }
        try test(.POST, "/admin/images/cleanup", withCSRFToken: false, afterResponse:  { response in
            XCTAssertEqual(response.status, .forbidden)
        })
        try test(.POST, "/admin/images/cleanup", afterResponse:  { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/images")
        })
        XCTAssertEqual(try Image.query(on: db).all().wait().count, 1)
    }
    
    func testCanDestroyAImage() throws {
        try app.imageRepository.save(image: "image".data(using: .utf8)!, for: "favicon")
        let image = DataMaker.makeImage(path: "/documents/imgs/favicon", altDescription: "favicon")
        try image.save(on: db).wait()
        try test(.POST, "/admin/images/1/delete", withCSRFToken: false, afterResponse:  { response in
            XCTAssertEqual(response.status, .forbidden)
        })
        try test(.POST, "/admin/images/1/delete", afterResponse:  { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/images")
        })
        XCTAssertEqual(try Image.query(on: db).all().wait().count, 0)
    }
    
    func testCanUpdateAImage() throws {
        try app.imageRepository.save(image: "image".data(using: .utf8)!, for: "favicon")
        let image = DataMaker.makeImage(path: "/documents/imgs/favicon", altDescription: "favicon")
        try image.save(on: db).wait()
        try test(.POST, "/admin/images/1/edit", body: "name=favicon_updated&altDescription=alt", withCSRFToken: false, afterResponse:  { response in
            XCTAssertEqual(response.status, .forbidden)
        })
        try test(.POST, "/admin/images/1/edit", body: "name=favicon_updated&altDescription=alt", afterResponse:  { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/images/1/edit")
        })
        try test(.GET, "/admin/images/1/edit", afterResponse:  { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("name")?.string, "favicon_updated")
            XCTAssertEqual(view.get("altDescription")?.string, "alt")
        })
    }
}

extension AdminImageControllerTests {
    public static let allTests = [
        ("testCanViewIndex", testCanViewIndex),
        ("testCanViewCleanButtonWhenHasNotFound", testCanViewCleanButtonWhenHasNotFound),
        ("testCanViewEditView", testCanViewEditView),
        ("testCanCleanUp", testCanCleanUp),
        ("testCanDestroyAImage", testCanDestroyAImage),
        ("testCanUpdateAImage", testCanUpdateAImage)
    ]
}
