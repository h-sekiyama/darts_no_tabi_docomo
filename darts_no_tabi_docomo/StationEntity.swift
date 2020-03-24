import Foundation

/// 駅情報のJSONに対応する構造体
struct StationEntity: Codable {
    
    // JSONのキー "ResultSet" に対応
    let ResultSet: ResultSetStruct
    
    /// JSONのキー "ResultSet" 部分を表す構造体
    struct ResultSetStruct: Codable {
        
        // JSONのキー "Point" に対応
        let Point: [PointStruct]
        
        /// JSONのキー "ResultSet" 部分を表す構造体
        struct PointStruct: Codable {
            
            // JSONのキー "Station" に対応
            let Station: [StationStruct]
            
            /// JSONのキー "Station" 内のオブジェクトを表す構造体
            struct StationStruct: Codable {
                let code: String
                let name: String
                let Yomi: String
            }
        }
    
    }
}
