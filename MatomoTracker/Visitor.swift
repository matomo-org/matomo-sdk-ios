import Foundation

struct Visitor: Codable {
    /// Unique ID per visitor (device in this case). Should be
    /// generated upon first start and never changed after.
    /// api-key: _id
    let id: String
    
    /// A unique visitor ID, possuble to override by the SDK user.
    /// api-key: cid
    let forcedID: String?
    
    /// An optional user identifier such as email or username.
    /// api-key: uid
    let userID: String?
}

extension Visitor {
    static func current(in matomoUserDefaults: MatomoUserDefaults) -> Visitor {
        var matomoUserDefaults = matomoUserDefaults
        let id: String
        if let existingID = matomoUserDefaults.clientID {
            id = existingID
        } else {
            let newID = newVisitorID()
            matomoUserDefaults.clientID = newID
            id = newID
        }
        let forcedVisitorID = matomoUserDefaults.forcedVisitorID
        let userID = matomoUserDefaults.visitorUserID
        return Visitor(id: id, forcedID: forcedVisitorID, userID: userID)
    }
    
    static func newVisitorID() -> String {
        let uuid = UUID().uuidString
        let sanitizedUUID = uuid.replacingOccurrences(of: "-", with: "")
        let start = sanitizedUUID.startIndex
        let end = sanitizedUUID.index(start, offsetBy: 16)
        return String(sanitizedUUID[start..<end])
    }
}
