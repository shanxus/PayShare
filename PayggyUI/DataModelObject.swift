//
//  EventObject.swift
//  PayggyUI
//
//  Created by Shan on 2017/5/28.
//  Copyright © 2017年 ShanStation. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

final class EventObject: Object {
    
    dynamic var eventName: String = ""
    
    dynamic var eventUID: String = ""
    
    convenience init(withEventName name: String, withUID uid: String) {
        self.init()
        
        self.eventName = name
        
        self.eventUID = uid
    }
    
    override static func primaryKey() -> String {
        
        return "eventUID"
    }
    
}

final class MemberObject: Object {
    
    dynamic var memberName: String = ""
    
    dynamic var memberUID: String = ""
    
    dynamic var belongEventUID: String = ""
    
    convenience init(withMemberName name: String, memberUID UID: String, belongTo eventUID: String) {
        self.init()
        
        self.memberName = name
        
        self.memberUID = UID
        
        self.belongEventUID = eventUID
    }
    
    override static func primaryKey() -> String {
        
        return "memberUID"
    }
}

final class PaymentObject: Object {
    
    dynamic var paymentName: String = ""
    
    dynamic var pay: Int = 0
    
    dynamic var paymentUID: String = ""
    
    dynamic var belongMemberUID: String = ""
    
    convenience init(withPaymentName name: String, withPay pay: Int, paymentUID UID: String, belongTO memberUID: String) {
        self.init()
        
        self.paymentName = name
        
        self.pay = pay
        
        self.paymentUID = UID
        
        self.belongMemberUID = memberUID
    }
    
    override static func primaryKey() -> String {
        
        return "paymentUID"
    }
}













