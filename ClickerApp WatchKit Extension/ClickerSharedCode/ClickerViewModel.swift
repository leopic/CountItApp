//
//  ClickerViewModel.swift
//  ClickerApp
//
//  Created by Christopher Jimenez on 3/10/16.
//  Copyright © 2016 greenpixels. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// View model for the clicker class
public class ClickerViewModel: NSObject{
    
    /// Data storage save information of the models
    let dataStorage : DataStorage = DataStorage()
    
    /// Watch session manager
    let watchSession : WatchSessionManager = WatchSessionManager.sharedManager
    
    /// Key to be use in the application context dictionary
    enum ApplicationContextKey: String{
        
        case ClikerKey = "clicker"
        
    }
    
    /// Clicker model
    public var clicker: Clicker = Clicker()
    {
        didSet{
           //If the value is set update the RXVariable with the value
            clickerCount.value = clicker.currentCount
            
        }
    }
    
    /// RX Variable of the count to be observed
    public var clickerCount =  Variable(0)
    
    /// The driver to be updated when changes happen
    public var clickerCountDriver: Driver<Int>?
    
    
    public override init(){
        
        super.init()
        /**
        Create the driver from the RX Variable
        */
        clickerCountDriver = clickerCount.asDriver()
        
        updateToLatestClicker()
        
        //Add view model to the datasource delegate so we get application context changes
        watchSession.addDataSourceChangedDelegate(self)
        
    }
    
    /**
     Get the latest clicker from storage or applicationContext
     
     - returns: clicker
     */
    public func updateToLatestClicker()
    {
        
        //Ge the clicker from storage
        var clicker: Clicker = dataStorage.getClicker()
        
        /// Check if we have the clicker dict in the application context
        if let clickerDict = watchSession.receivedApplicationContext?[ApplicationContextKey.ClikerKey.rawValue] as? [String : AnyObject]
        {
            //Get the clicker object from the application Context
            let clickerFromApplicationContext = Clicker(dictionary: clickerDict)
            
            //Get the most resent clicker that we have in storage
            let clickerFromStorage = dataStorage.getClicker()
            
            //If the clicker from the application context is more update than the one of storage
            if clickerFromApplicationContext > clickerFromStorage{
                //Use the clicker from aplication context
                clicker = clickerFromApplicationContext
            }
            else
            {
                //Use the clicker from storage
                clicker = clickerFromStorage
            }
        }
        
        self.clicker = clicker
    }
    
    
    /**
     Increment the clicker count and update its datastorage and application context
     */
    public func incrementClikerByMultiplier(multiplier: Int = 1){
    
        clicker.incrementCountByMultiplier(multiplier)
        
        saveAndUpdateCliker()
    }
    
    /**
     Decrement the clicker and update its datastorage and application context
     */
    public func decrementClikerByMultiplier(multiplier: Int = 1){
        
        clicker.decrementCountByMultiplier(multiplier)
            
        saveAndUpdateCliker()
    }
    
    /**
     Reset the clicker and update datastorage
     */
    public func resetClicker(){
        
        clicker.resetCount()
            
        saveAndUpdateCliker()
    }
    
    
    /**
     Save the clicker to dataStorage and update the application context with the information of the clicker
     */
    private func saveAndUpdateCliker()
    {
        clickerCount.value = clicker.currentCount

        dataStorage.saveClicker(clicker)
        
        watchSession.updateApplicationContext(withKey: ApplicationContextKey.ClikerKey.rawValue, content: clicker.toDictionary())
    }
    
    
    deinit{
        
        //Add view model to the datasource delegate so we get application context changes
         watchSession.removeDataSourceChangedDelegate(self)
        
    }

}

// MARK: - Extension to implement the ApplicationContextChangedDelegate of the info sent by the watch and the iOS device
extension ClickerViewModel: ApplicationContextChangedDelegate{
    
    
    // MARK: DataSourceUpdatedDelegate
    public func applicationContextDidUpdate(applicationContext: [String : AnyObject]) {
        
        if let clickerDict = applicationContext[ApplicationContextKey.ClikerKey.rawValue] as? [String:AnyObject]{
            
            
            self.clicker = Clicker(dictionary: clickerDict)
            
        }
    }
    
}
