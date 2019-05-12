//
//  Constants.swift
//  guesLogixChallenge
//
//  Created by Syed Abdul Basit on 2019-05-12.
//  Copyright © 2019 Syed Abdul Basit. All rights reserved.
//

import Foundation
import UIKit


//MARK: - File Information

enum FILE {
    static let AIRPORTS = "airports"
    static let AIRLINES = "airlines"
    static let ROUTES = "routes"
}


enum APPID {
    static let GOOGLE_MAP_API_KEY = "AIzaSyCJYiT5IU0WW4b-h2LXQ6mE9x2VGxVRyig"
}

//MARK: - Alert Message Text
enum AlertMessages {
    static let k_BAD_ORIGIN = "Origin airport can't be empty and it has to be 3 letters long. Please try again"
    static let k_BAD_DESTINATION = "Destination airport can't be empty and it has to be 3 letters long. Please try again"
    static let k_EMPTY_INPUTS = "Fields can't be empty please write origin and destination codes"
    static let k_NO_ORIGIN = "Origin airport not found"
    static let k_NO_DESTINATION = "Destination airport not found"
    static let k_SAME_DESTINATIONS = "Origin and Destination can't be the same.Please change one and try again"
    static let k_NO_ROUTE = "We could not find a suitable route for these options. Please try again with different destinations"
}

