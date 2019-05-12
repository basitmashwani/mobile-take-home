//
//  RouteViewController.swift
//  GuestlogixTest
//
//  Created by Syed Abdul Basit on 2019-05-12.
//  Copyright © 2019 Syed Abdul Basit. All rights reserved.
//

import UIKit
import GoogleMaps
import Foundation






class RouteViewController: UIViewController {

    @IBOutlet weak var txtOrigin: UITextField!
   
    @IBOutlet weak var txtDestination: UITextField!
    
    @IBOutlet weak var btnSearch: UIButton!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    
    // arrays to hold the csv data
    var airportsData = [[String]]()
    
    var airlinesData = [[String]]()
    
    var routesData = [[String]]()
    
    // stores all the
    var tempRoute = [String]()
    
    var routeCount = Int()
    
    
    // storing all possible routes while searching for paths
    var nextRoutesToBeTested = [[[String]]]()
    
    var tempCount = 0
    
    var secondCount = 0
    
    var flattenedPositionCount = Int()
    
    var destinationExists = Bool()
    
    var routeExists = Bool()
    
    var camera = GMSCameraPosition.camera(withLatitude: 43.6532, longitude: -79.3832, zoom: 6.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.camera = camera

        readFiles()
        
        // auto-capitalizing both textfield
        txtOrigin.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        
        txtDestination.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        
        //hides the keyboard when anywhere else on the screen besides textboxes is tapped
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    
    
    @IBAction func searchPressed(_ sender: Any) {
        
        routeCount = 0
        tempCount = 0
        secondCount = 0
        flattenedPositionCount = 0
        
        nextRoutesToBeTested.removeAll()
        tempRoute.removeAll()
        
        destinationExists = false
        routeExists = false
        

        
        guard let originIATA = txtOrigin.text?.trimmed, !originIATA.isEmptyTrimmed else{
           
            showNotificationMessage("", message: AlertMessages.k_BAD_ORIGIN, type: .error)
            return
        }
        
        guard let destinationIATA = txtDestination.text?.trimmed, !destinationIATA.isEmptyTrimmed else{

            showNotificationMessage("", message: AlertMessages.k_BAD_DESTINATION, type: .error)

            return
        }
        
        // checks for the validity of the inputs
        if(validateInputs(originIATA, destinationIATA)){
        
            // add the origin IATA to the root of test list 
            nextRoutesToBeTested.append([[originIATA]])
    
            // check all existing routes/paths
             checkPath(originIATA, destinationIATA)
            
            // clear the array once the routes have been found
            nextRoutesToBeTested.removeAll()
            
            // add the markers to the map
            addMarkers()
            
            
        }
        
   
        
    }
    
    
    

    // goes through all the list of routes and finds the first one found (BFS)
    
    func checkPath(_ originIATA : String, _ destinationIATA : String)  {
        
        // temporary origin to be used for each iteration
        var tempOriginIATA = originIATA
    
        // this will be iterated for each origin along the possible routes
        while true{
        
            for i in 0..<routesData.count{
                
                // first, check if the destination actually exists on the route list (as some do not, e.g. DNV), before going through the loop
                if((routesData[i][2].caseInsensitiveCompare(destinationIATA.trimmed)) == ComparisonResult.orderedSame ){
                    
                    destinationExists = true
                    
                }
                
                //  check from the origin IATA
                if(
                    (routesData[i][1].caseInsensitiveCompare(tempOriginIATA.trimmed)) == ComparisonResult.orderedSame
                ){
                    
                    
                    routeExists = true
                    
                    
                    // destination found in the current route
                    if( (routesData[i][2].caseInsensitiveCompare(destinationIATA.trimmed)) == ComparisonResult.orderedSame ){
                     
                        tempRoute.append(tempOriginIATA.trimmed)
                        tempRoute.append(destinationIATA.trimmed)
                        
                        // trace backwards
                        var i = routeCount
                    
                        while(i > 0){
                        
                            
                          
                            
                            let previousArrayFlattned = Array(nextRoutesToBeTested[i-1].joined())
                            
                            // insert to the route list (going backwards, so append to the beginning)
                            tempRoute.insert(previousArrayFlattned[secondCount], at: 0)
                            
                            // parent IATA found at this point
                            
                            // need to get secondCount (2nd level index) for the next iteration of the traceback
                            var tempArrayCount = 0
                            var tempElementCount = secondCount + 1 // adding 1 b/c it's a count instead of an index
                            
                            // getting the flattened position of the previous array using the 2nd level count of the current position
                            while(tempElementCount > 0){
                                tempElementCount -= nextRoutesToBeTested[i-1][tempArrayCount].count
                                tempArrayCount += 1
                                // move on to the next array
                            }
                            
                            secondCount = tempArrayCount-1 // subtracting 1 b/c it's an index
                            
                            
                            i -= 1
                        }
                        
                        routeCount += 1
                        
                        return
                    }
                        
                    // if destination not found in the current route, add it to the next level in the array so that is looked up after the lookup in the current level is complete
                    else{
                    
                        // initializing the array if empty
                        // if it's a new level of route
                        if( !nextRoutesToBeTested.indices.contains(routeCount+1) ){
                            
                           nextRoutesToBeTested.append([[routesData[i][2]]])
                            
                            
                        }
                        
                        // if it's from a new parent IATA (need to be created in a new array)
                        else if(!(nextRoutesToBeTested[routeCount+1].indices.contains(flattenedPositionCount))){
                            nextRoutesToBeTested[routeCount+1].append([routesData[i][2]])
                        }
                        
                        // else, add it to the existing last array
                        else{
                           
                            nextRoutesToBeTested[routeCount+1][flattenedPositionCount].append(routesData[i][2])
                        }
                        
                        
                    }
                    
                    
                }
              
        
            }
            
            // if no routes exist from the origin,
            // or destion does not exist from the route list,
            // or if destination not found after 7 levels
            // (assupmtion: no possible routes go over 7 stops, realistically, and to prevent infinite loops)
            if(!routeExists) || (!destinationExists) || (routeCount >= 7) {
               
               showNotificationMessage("", message: AlertMessages.k_NO_ROUTE, type: .error)
                
                tempRoute.removeAll()
                
                return
            }
            
            
            tempCount += 1
            flattenedPositionCount += 1
            
            // end of a 3rd level array - increment the 2nd level counter and rest the 3rd level counter for the next iteration
            if(tempCount >= nextRoutesToBeTested[routeCount][secondCount].count){
                secondCount += 1
                tempCount = 0
            }
            
            // end of a 2nd level array - increment routeCount (basically the 1st level counter), and reset the 2nd / 3rd / flattened position counts
            if(secondCount >= nextRoutesToBeTested[routeCount].count){
                
                
                flattenedPositionCount = 0
                tempCount = 0
                secondCount = 0
                routeCount += 1

            }
            
            
            // if the next level of routes exist, then set the next origin for the next iteration
            if(nextRoutesToBeTested.indices.contains(routeCount)){
                tempOriginIATA = nextRoutesToBeTested[routeCount][secondCount][tempCount]
            }
            
            else{
                return
                }
            
        
        }
        
        
        
    }
    
    
   public func getRoute()->[String] {
        
        return tempRoute
    }
    
    // validating the inputs
    func validateInputs(_ originIATA: String, _ destinationIATA: String) -> Bool {
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
       
            var txtOriginIsValid : Bool = false
            var txtDestinationIsValid : Bool = false
        
            var i = 0
        
        
            // if origin and destination are the same
            // catching it before going through all the list of IATAs so that it doesnt have to go through the list if both entries are identical
            if((txtOrigin.text!.trimmed.caseInsensitiveCompare(txtDestination.text!.trimmed)) == ComparisonResult.orderedSame){
                
               showNotificationMessage("", message: AlertMessages.k_SAME_DESTINATIONS, type: .error)
            
                return false
            
            }
        
        
            // going through IATAs
            while((!txtOriginIsValid || !txtDestinationIsValid) &&  i < airportsData.count){
                
                // if the IATA code for the origin is found
                if((airportsData[i][3].caseInsensitiveCompare(txtOrigin.text!.trimmed)) == ComparisonResult.orderedSame
                    && !txtOriginIsValid){
                    
                    txtOriginIsValid = true
    
                }
                
                // if the IATA code for the origin is found
                if((airportsData[i][3].caseInsensitiveCompare(txtDestination.text!.trimmed)) == ComparisonResult.orderedSame
                    && !txtDestinationIsValid){
                    
                    txtDestinationIsValid = true
                }
                
                i += 1
              }
        
            // invalid origin and/or destination IATA
            if(!txtOriginIsValid || !txtDestinationIsValid){
                
                
                // origin invalid
                if(!txtOriginIsValid){
                    
                    showNotificationMessage("", message: AlertMessages.k_NO_ORIGIN, type: .error)
                }
                    
                else{
                    showNotificationMessage("", message: AlertMessages.k_NO_DESTINATION, type: .error)

                }
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                return false
            }
                // both inputs valid
            else{
                // only hide keyboard when the entries are valid
                dismissKeyboard()
                
                return true
            }
        
    }
    
    // returns the basic info about the airport (used for mapView)
    func getAirportDetails(_ IATA: String) -> [String]{
        
        var returnString = [String]()
        
        for i in 0..<airportsData.count{
            
            if((airportsData[i][3].caseInsensitiveCompare(IATA.trimmed)) == ComparisonResult.orderedSame){
                returnString = airportsData[i]
                
            }
        }
        
        return returnString
        
        
    }
    
    
    

    // adds all markers for all of the airports to be visited, once the route is determined
    func addMarkers(){
        
        mapView.clear()
        
        var bounds = GMSCoordinateBounds()
        let path = GMSMutablePath()
        
        // for each of the destinations on the route
        for i in 0..<tempRoute.count{
    
            // temporary airport entry / latitude / longtitude for each point to be visited
            var tempAirportEntry = getAirportDetails(tempRoute[i])
            let tempLatitude = Double(tempAirportEntry[4])!
            let tempLongitude = Double(tempAirportEntry[5])!
            
            let camera = GMSCameraPosition.camera(withLatitude: tempLatitude, longitude: tempLongitude, zoom: 5.0)
            mapView.camera = camera
        
            // create a marker on the map for each of the stops to be visited,
            // containing the info on the airport
            let marker = GMSMarker()
            marker.position = camera.target
            marker.title = tempAirportEntry[0]
            marker.snippet = tempAirportEntry[1] + ", " + tempAirportEntry[2]
            marker.map = mapView
            
            // adding bounds to be fitted on the map
            bounds = bounds.includingCoordinate(marker.position)
            
            // coordinates for adding lines on the map for each of the stops
            let coord = CLLocationCoordinate2DMake(tempLatitude, tempLongitude)
            path.add(coord)
            
         
            
        }
        
        // fitting the bounds on the map
        let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 100)
        mapView.animate(with: cameraUpdate)
    
        // addling lines on the map for each of the stops
        let line = GMSPolyline(path: path)
        line.strokeColor = UIColor.blue
        line.strokeWidth = 3.0
        line.map = self.mapView
        
        
        
    
    }
    
    //hiding the keyboard back when the textboxes are not selected anymore
    @objc func keyboardWillHide(_ notification: Notification) {
  
        if (((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
          
            self.view.frame.origin.y = 0
            
        }
    }

    
    
}




    
    


