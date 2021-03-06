import Vapor

struct ImageForm: Form, Content {

    private enum CodingKeys: String, CodingKey {
        case name
        case altDescription
    }

    let name: String
    let altDescription: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name).requireAllowedPath()
        altDescription = try container.decode(String.self, forKey: .altDescription)
    }
}
