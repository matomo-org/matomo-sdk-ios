
import Foundation


/// See Custom Variable documentation here: https://piwik.org/docs/custom-variables/
public struct CustomVariable {
    /// The index of the variable.
    let index: UInt

    /// The name of the variable.
    let name: String
    
    /// The value of the variable.
    let value: String
}
