//
//  Constants.swift
//  guesLogixChallenge
//
//  Created by Syed Abdul Basit on 2019-05-12.
//  Copyright © 2019 Syed Abdul Basit. All rights reserved.
//


import XCTest
@testable import GuestlogixChallenge

class guesLogixChallengeTests: XCTestCase {
    var viewControllerInstance: RouteViewController!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewControllerInstance = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RouteViewController") as! RouteViewController)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    //MARK: Loading tests
    
    func testLoadingRoutes() {
        let stringData = viewControllerInstance.readDataFromCSV(fileName: "routes", fileType: "csv")
        let rows = stringData?.components(separatedBy: "\n") ?? []
        let header = rows[0]
        XCTAssertEqual(header, "Airline Id,Origin,Destination")
    }
    
    func testLoadingAirports() {
        let stringData = viewControllerInstance.readDataFromCSV(fileName: "airports", fileType: "csv")
        let rows = stringData?.components(separatedBy: "\n") ?? []
        let header = rows[0]
        XCTAssertEqual(header, "Name,City,Country,IATA 3,Latitute ,Longitude")
    }
    
    func testLoadingAirlines() {
        let stringData = viewControllerInstance.readDataFromCSV(fileName: "airlines", fileType: "csv")
        let rows = stringData?.components(separatedBy: "\n") ?? []
        let header = rows[0]
        XCTAssertEqual(header, "Name,2 Digit Code,3 Digit Code,Country")
    }
    

    //MARK: Routing test
    func testRouting() {

        
        let originIATA = "ISB"
        let destinationIATA = "DXB"
        
        viewControllerInstance.readFiles()
            // add the origin IATA to the root of test list
            viewControllerInstance.nextRoutesToBeTested.append([[originIATA]])
            
            // check all existing routes/paths
            viewControllerInstance.checkPath(originIATA, destinationIATA)
            
        
            
        
        // if route count is equal to 3 then test it pass.
        
        XCTAssertEqual(viewControllerInstance.tempRoute.count,3)
    }
}

