//
//  DataManger.swift
//  GuestlogixTest
//
//  Created by Syed Abdul Basit on 2019-05-12.
//  Copyright © 2018 Syed Abdul Basit. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import SwiftMessages


extension RouteViewController {
    
    
    
    // method to read data from CSV
    func readDataFromCSV(fileName:String, fileType: String)-> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
            else {
                print("file nil")
                return nil
        }
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }

    
    // to clean up the newline characters just in case
    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        
        return cleanFile
    }
    
    
    // parse each row of the CSV file
    func parseCSVData(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
    
    // read all three files
    func readFiles(){
        

        var airlinesDataTemp = readDataFromCSV(fileName: "airlines", fileType: "csv")
        
        airlinesDataTemp = cleanRows(file: airlinesDataTemp!)
        airlinesData = parseCSVData(data: airlinesDataTemp!)
        
        
        var routesDataTemp = readDataFromCSV(fileName: "routes", fileType: "csv")
        
        routesDataTemp = cleanRows(file: routesDataTemp!)
        routesData = parseCSVData(data: routesDataTemp!)
        
        var airportsDataTemp = readDataFromCSV(fileName: "airports", fileType: "csv")
        
        airportsDataTemp = cleanRows(file: airportsDataTemp!)
        airportsData = parseCSVData(data: airportsDataTemp!)
      
        
    }
    
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
   

    
    func showNotificationMessage(_ title:String,message:String,type:Theme) {
        
        
        let view = MessageView.viewFromNib(layout: .cardView)
        
        // Theme message elements with the warning style.
        view.configureTheme(type)
        
        // Add a drop shadow.
        view.configureDropShadow()
        
        // Set message title, body, and icon. Here, we're overriding the default warning
        // image with an emoji character.
        //  let iconText = ["🤔", "😳", "🙄", "😶"].sm_random()!
        //   view.configureContent(title: "Error", body: "Please Enter Email": iconText)
        view.configureContent(title: title, body: message)
        view.button?.isHidden = true
        // Show the message.
        SwiftMessages.show(view: view)
    }

    
}


extension String {
    
    // checks for empty strings after trimming
    var isEmptyTrimmed: Bool {
        return self.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
    }
    
    // returns strings with whitespaces trimmed
    var trimmed : String{
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
}
