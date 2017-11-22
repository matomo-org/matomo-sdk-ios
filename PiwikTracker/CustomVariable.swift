
import Foundation


/// See Custom Variable documentation here: https://piwik.org/docs/custom-variables/
public struct CustomVariable {
 
    /// The index of the variable. Must be > 0. When using default custom vars, indices 1-3
    /// are reserved.
//    let index: Int
    
    /// The name of the variable.
    let name: String
    
    /// The value of the variable.
    let value: String
}
