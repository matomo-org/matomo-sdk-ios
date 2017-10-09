import Foundation

public struct CustomDimension {
    /// The index of the dimension. A dimension with this index must be setup in the piwik backend.
    let index: Int
    
    /// The value you want to set for this dimension.
    let value: String
}
