import Vapor
import AuthProvider

final class AdminRoutes: RouteCollection, EmptyInitializable {
    
    func build(_ builder: RouteBuilder) throws {
        
        let sessionGroup = builder.grouped(PersistMiddleware<User>())
        
        // Login
        let login = sessionGroup.grouped(InverseRedirectMiddleware<User>.home(path: "admin/posts"))
        login.resource("login", LoginController())
        
        // Logout
        sessionGroup.resource("logout", LogoutController())
        
        let admin = sessionGroup.grouped([
            RedirectMiddleware.login(),
            PasswordAuthenticationMiddleware<User>()
        ]).grouped("admin")
        
        let adminPostController = AdminPostController()
        
        admin.editableResource("tags", AdminTagController())
        admin.editableResource("categories", AdminCategoryController())
        admin.editableResource("posts", adminPostController)
        admin.editableResource("images", AdminImageViewController())
        admin.resource("siteinfo/edit", AdminSiteInfoController())
        admin.resource("user/edit", AdminUserController())
        admin.get("static-contents", handler: adminPostController.indexStaticContent)
    }
}
