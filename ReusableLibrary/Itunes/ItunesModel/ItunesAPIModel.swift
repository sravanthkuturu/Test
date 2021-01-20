//
//  ItunesAPIModel.swift
//  ReusableLibrary
//
//  Created by Sravanth Kuturu on 20/01/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct ItunesAPIModel: Codable {
    let resultCount: Int?
    let results: [ItunesResult]?
}

// MARK: - Result
struct ItunesResult: Codable {
    let wrapperType, artistType, artistName: String?
    let artistLinkURL: String?
    let artistID, amgArtistID: Int?
    let primaryGenreName: String?
    let primaryGenreID: Int?
    
    enum CodingKeys: String, CodingKey {
        case wrapperType, artistType, artistName
        case artistLinkURL = "artistLinkUrl"
        case artistID = "artistId"
        case amgArtistID = "amgArtistId"
        case primaryGenreName
        case primaryGenreID = "primaryGenreId"
    }
}
