//
//  SearchResults.swift
//  StoreSearch
//
//  Created by c.toan on 17.09.2022.
//

import Foundation

class ResultArray: Codable {
    var resultCount = 0
    var results = [SearchResults]()
}
class SearchResults: Codable, CustomStringConvertible {
    var description: String {
        return "\nResult - Name: \(name), Artist Name: - \(artistName ?? "None")"
    }
    
    var artistName: String? = ""
    var trackName: String? = ""
    
    var name: String {
        return trackName ?? ""
    }
}
