//
//  InterfaceController.swift
//  Weather_WatchApp Extension
//
//  Created by Mayuko Inoue on 2/20/17.
//  Copyright © 2017 mayuko. All rights reserved.
//

import WatchKit
import Foundation

enum JSONError: String, Error {
  case NoData = "ERROR: no data"
  case ConversionFailed = "ERROR: conversion from JSON failed"
}

class InterfaceController: WKInterfaceController {

  @IBOutlet var locationLabel: WKInterfaceLabel!
  @IBOutlet var forecastLabel: WKInterfaceLabel!
  @IBOutlet var tempLabel: WKInterfaceLabel!
  
  let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
  var dataTask: URLSessionDataTask?
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    // Configure interface objects here.
    
    if dataTask != nil {
      dataTask?.cancel()
    }
    
    let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=London,uk&units=imperial&appid=f31bcc217a20fabdd80f0a391bb4ad4e")
    
    dataTask = defaultSession.dataTask(with: url!) {
      data, response, error in
      
      if let error = error {
        print(error.localizedDescription)
      } else if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
          
          do {
            guard let data = data else {
              throw JSONError.NoData
            }
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
              throw JSONError.ConversionFailed
            }
            let dataDict = json as! [String : Any]
            self.locationLabel.setText(dataDict["name"] as? String)
            
            /*
             "weather": [{
               "id": 803,
               "main": "Clouds",
               "description": "broken clouds",
               "icon": "04n"
             }]
             */
            let weatherDict = dataDict["weather"] as? [[String: Any]]
            self.forecastLabel.setText(weatherDict?[0]["description"] as! String?)
            
            /*
             "main": {
               "temp": 52.02,
               "pressure": 1021.02,
               "humidity": 83,
               "temp_min": 52.02,
               "temp_max": 52.02,
               "sea_level": 1028.64,
               "grnd_level": 1021.02
             },
             */
            let mainDict = dataDict["main"] as? [String: Any]
            self.tempLabel.setText("\(mainDict?["temp"] as! Double) degrees")
            
          } catch let error as JSONError {
            print(error.rawValue)
          } catch let error as NSError {
            print(error.debugDescription)
          }
        }
      }
    }
    dataTask?.resume()
  }
  
  override func willActivate() {
      // This method is called when watch view controller is about to be visible to user
      super.willActivate()
  }
  
  override func didDeactivate() {
      // This method is called when watch view controller is no longer visible
      super.didDeactivate()
  }

}
