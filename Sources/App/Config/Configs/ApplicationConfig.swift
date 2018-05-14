import Vapor

struct ApplicationConfig: LocalConfig, Service {
    
    static var fileName: String {
        return "note"
    }
    
    let messageFormat: String?
    let hostName: String
    let dateFormat: String
    let meta: Meta?
    
    struct Meta: Content {
        let pageDescription: String
        let pageImage: String
        let twitter: TwitterMeta?
    }
    
    struct TwitterMeta: Content {
        let imageAlt: String
        let username: String
    }
}