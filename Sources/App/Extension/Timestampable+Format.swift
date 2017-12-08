import Foundation
import FluentProvider

extension Timestampable {
    
    private var dateFormat: String {
        return "yyyy-MM-dd HH:mm"
    }
    
    var formattedCreatedAt: String? {

        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        return createdAt.map { formatter.string(from: $0) }
    }
    
    var formattedUpdatedAt: String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        return updatedAt.map { formatter.string(from: $0) }
    }
}