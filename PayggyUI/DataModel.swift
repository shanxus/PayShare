//
//  DataModel.swift
//  PayggyUI
//
//  Created by Shan on 2017/5/26.
//  Copyright © 2017年 ShanStation. All rights reserved.
//

import Foundation

struct Event {
    
    var eventName: String
    
    var eventUID: String
    
    var memberArray: [Member]
    
    var eventTotalCost: Int {
        
        var totalPaid = 0
        
        for member in memberArray {
            
            totalPaid += member.totalPaid
        }
        
        return totalPaid
    }
    
    init(withName name: String, withUID uid: String) {
        
        self.eventName = name
        
        self.eventUID = uid
        
        self.memberArray = Array()
    }
}

struct Member {
    
    var memberName: String
    
    var memberUID: String
    
    var belongEventUID: String
    
    var payment: [Int]
    
    var paymentName: [String]
    
    var paymentUID: [String]
    
    var totalPaid: Int {
        
        var obj = 0
        
        for i in payment {
            
            obj += i
        }
        
        return obj
    }
    
    init(withName name: String, withMemberUID memberUID: String, withEventUID eventUID: String) {
        
        self.memberName = name
        
        self.memberUID = memberUID
        
        self.belongEventUID = eventUID
        
        self.payment = Array()
        
        self.paymentName = Array()
        
        self.paymentUID = Array()
    }
}







