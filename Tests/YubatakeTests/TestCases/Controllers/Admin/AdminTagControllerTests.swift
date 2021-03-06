@testable import App
import XCTVapor

final class AdminTagControllerTests: ControllerTestCase {
    
    func testCanViewIndex() throws {
        try test(.GET, "/admin/tags", afterResponse:  { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("items")?.array?.count, 0)
        })
        let tag = DataMaker.makeTag(name: "Swift")
        try tag.save(on: db).wait()
        try test(.GET, "/admin/tags", afterResponse:  { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("items")?.array?.count, 1)
            XCTAssertEqual(view.get("metadata.total")?.int, 1)
            XCTAssertEqual(view.get("metadata.page")?.int, 1)
            XCTAssertEqual(view.get("metadata.totalPage")?.int, 1)
        })
    }
    
    func testCanViewPageButtonAtTwoPages() throws {
        try (1...11).forEach { i in
            let tag = DataMaker.makeTag(name: String(i))
            try tag.save(on: db).wait()
        }
        try test(.GET, "/admin/tags", afterResponse:  { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("metadata.total")?.int, 11)
            XCTAssertEqual(view.get("metadata.page")?.int, 1)
            XCTAssertEqual(view.get("metadata.totalPage")?.int, 2)
        })
        try test(.GET, "/admin/tags?page=2", afterResponse:  { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("metadata.total")?.int, 11)
            XCTAssertEqual(view.get("metadata.page")?.int, 2)
            XCTAssertEqual(view.get("metadata.totalPage")?.int, 2)
        })
    }
    
    func testCanViewCreateView() throws {
        try test(.GET, "/admin/tags/create", afterResponse:  { response in
            XCTAssertEqual(response.status, .ok)
        })
    }
    
    func testCanViewEditView() throws {
        let tag = DataMaker.makeTag(name: "Swift")
        try tag.save(on: db).wait()
        try test(.GET, "/admin/tags/1/edit", afterResponse:  { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("name")?.string, "Swift")
        })
    }
    
    func testCanDestroyATag() throws {
        let tag = DataMaker.makeTag(name: "Swift")
        try tag.save(on: db).wait()
        try test(.POST, "/admin/tags/delete", body: "tags[]=1", withCSRFToken: false, afterResponse:  { response in
            XCTAssertEqual(response.status, .forbidden)
        })
        try test(.POST, "/admin/tags/delete", body: "tags[]=1", afterResponse:  { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/tags")
        })
        try test(.GET, "/admin/tags", afterResponse:  { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("items")?.array?.count, 0)
        })
    }
    
    func testCanStoreATag() throws {
        try test(.POST, "/admin/tags", body: "name=Swift", withCSRFToken: false, afterResponse:  { response in
            XCTAssertEqual(response.status, .forbidden)
        })
        try test(.POST, "/admin/tags", body: "name=Swift", afterResponse:  { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/tags/1/edit")
        })
        try test(.GET, "/admin/tags/1/edit", afterResponse:  { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("name")?.string, "Swift")
        })
    }
    
    func testCannotStoreInvalidNameTag() throws {
        try test(.POST, "/admin/tags", body: "name=", afterResponse:  { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/tags/create")
        })
        try test(.GET, "/admin/tags/create", afterResponse:  { response in
            XCTAssertNotNil(view.get("errorMessage"))
        })
        let longName = String(repeating: "a", count: 17)
        try test(.POST, "/admin/tags", body: "name=\(longName)", afterResponse:  { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/tags/create")
        })
        try test(.GET, "/admin/tags/create", afterResponse:  { response in
            XCTAssertNotNil(view.get("errorMessage"))
        })
    }
    
    func testCannotCreateTagAtAlreadyExist() throws {
        let tag = DataMaker.makeTag(name: "Swift")
        try tag.save(on: db).wait()
        try test(.POST, "/admin/tags", body: "name=Swift", afterResponse:  { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/tags/create")
        })
    }
    
    func testCanUpdateATag() throws {
        let tag = DataMaker.makeTag(name: "Swift")
        try tag.save(on: db).wait()
        try test(.POST, "/admin/tags/1/edit", body: "name=Kotlin", withCSRFToken: false, afterResponse:  { response in
            XCTAssertEqual(response.status, .forbidden)
        })
        try test(.POST, "/admin/tags/1/edit", body: "name=Kotlin", afterResponse:  { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/tags/1/edit")
        })
        try test(.GET, "/admin/tags/1/edit", afterResponse:  { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(view.get("name")?.string, "Kotlin")
        })
    }
    
    func testCannotUpdateToInvalidNameCategory() throws {
        let tag = DataMaker.makeTag(name: "Swift")
        try tag.save(on: db).wait()
        let longName = String(repeating: "a", count: 17)
        try test(.POST, "/admin/tags/1/edit", body: "name=\(longName)", afterResponse:  { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: .location), "/admin/tags/1/edit")
        })
        try test(.GET, "/admin/tags/1/edit", afterResponse:  { response in
            XCTAssertNotNil(view.get("errorMessage"))
        })
        XCTAssertEqual(try Tag.find(1, on: db).wait()?.name, "Swift")
    }
}

extension AdminTagControllerTests {
    public static let allTests = [
        ("testCanViewIndex", testCanViewIndex),
        ("testCanViewPageButtonAtTwoPages", testCanViewPageButtonAtTwoPages),
        ("testCanViewCreateView", testCanViewCreateView),
        ("testCanViewEditView", testCanViewEditView),
        ("testCanDestroyATag", testCanDestroyATag),
        ("testCanStoreATag", testCanStoreATag),
        ("testCannotStoreInvalidNameTag", testCannotStoreInvalidNameTag),
        ("testCannotCreateTagAtAlreadyExist", testCannotCreateTagAtAlreadyExist),
        ("testCanUpdateATag", testCanUpdateATag),
        ("testCannotUpdateToInvalidNameCategory", testCannotUpdateToInvalidNameCategory)
    ]
}
