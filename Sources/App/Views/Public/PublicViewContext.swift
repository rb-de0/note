import CSRF
import Vapor

final class PublicViewContext: ApplicationHelper {
    
    // MARK: - Class
    
    private static var viewRenderer: ViewRenderer!
    
    static func setup(_ drop: Droplet) {
        viewRenderer = drop.view
    }
    
    // MARK: - Instance
    
    private var title: String?
    private let path: String
    
    init(path: String, title: String? = nil) {
        self.path = path
        self.title = title
    }
    
    func addTitle(_ title: String?) -> Self {
        self.title = title
        return self
    }
    
    func makeResponse(context: NodeRepresentable = Node(ViewContext.shared), for request: Request) throws -> View {
        
        var node = try context.makeNode(in: ViewContext.shared)
        
        // common data
        let siteInfo = try SiteInfo.shared()
        try node.set("csrf_token", try CSRF().createToken(from: request))
        try node.set("site_info", siteInfo.makeJSON())
        try node.set("recent_posts", try Post.recentPosts().makeJSON())
        try node.set("static_contents", try Post.staticContents().makeJSON())
        
        // page informations
        let config = ConfigProvider.app
        try node.set("page_title", title ?? siteInfo.name)
        try node.set("page_url", request.uri.makeFoundationURL().absoluteString)
        try node.set("meta", config?.meta?.makeJSON())
        
        do {
            let view = try type(of: self).viewRenderer.make(FileHelper.userDirectoryName.finished(with: "/") + path, node, for: request)
            return view
        } catch let error as DataFileError {
            if case .load(_) = error {
                return try type(of: self).viewRenderer.make(path, node, for: request)
            } else {
                throw error
            }
        } catch {
            throw error
        }
    }
}
