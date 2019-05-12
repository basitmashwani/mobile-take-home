//
//  AppDelegate.swift
//  GuestlogixTest
//
//  Created by Syed Abdul Basit on 2019-05-12.
//  Copyright © 2019 Syed Abdul Basit. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //2
        GMSServices.provideAPIKey(APPID.GOOGLE_MAP_API_KEY)
        return true
    }
}

