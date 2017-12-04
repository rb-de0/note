import FluentProvider
import LeafProvider

extension Config {
    public func setup() throws {
        
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
    }
    
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(LeafProvider.Provider.self)
    }
    
    private func setupPreparations() throws {
        preparations = [
            Post.self,
            Category.self,
            Tag.self,
            User.self,
            Pivot<Post, Tag>.self
        ]
    }
}