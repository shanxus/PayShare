//
//  ViewController.swift
//  PayggyUI
//
//  Created by Shan on 2017/5/26.
//  Copyright © 2017年 ShanStation. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, updateEventDelegate {

    @IBOutlet weak var tableView: UITableView!

    var eventArray: [Event] = Array()
    
    // 記錄哪一個 cell 被選取
    var tappedCell: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationItem.title = NSLocalizedString("overviewPageTitle", comment: "The navigation item title of overview page")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        queryEventsFromRealm()
        
    }

    @IBAction func addEvent(_ sender: Any) {
    
        let addEventTitle = NSLocalizedString("addEventTitle", comment: "The title of Add Event AlertController")
        
        let addEventMessage = NSLocalizedString("addEventMessage", comment: "The message of Add Event AlertController")
        
        let addEventAlertController = UIAlertController(title: addEventTitle, message: addEventMessage, preferredStyle: .alert)
        
        addEventAlertController.addTextField { (textField: UITextField!) in
            
            let eventNamePlaceholder = NSLocalizedString("eventNamePlaceholder", comment: "The placeholder of the event name.")
            
            textField.placeholder = eventNamePlaceholder
        }
        
        let cancelLString = NSLocalizedString("cancelLString", comment: "The cancel action")
        
        let cancelAction = UIAlertAction(title: cancelLString, style: .cancel, handler: nil)
        
        addEventAlertController.addAction(cancelAction)
        
        let addLString = NSLocalizedString("addLString", comment: "The add action")
        
        let addEventAction = UIAlertAction(title: addLString, style: .default) { (action: UIAlertAction) in
            
            guard let eventName = addEventAlertController.textFields?.first!.text else { return }
            
            self.addEvent(withEventName: eventName)
        }
        
        addEventAlertController.addAction(addEventAction)
        
        self.present(addEventAlertController, animated: true, completion: nil)
        
    }
    
    
    func addEvent(withEventName eventName: String) {
        
        let newEventUid = UUID().uuidString
        
        let newEvent = Event(withName: eventName, withUID: newEventUid)
        
        self.eventArray.append(newEvent)
        
        self.tableView.reloadData()
        
        updateEventInRealm(withEventName: eventName, withEventUID: newEventUid)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toEventPage" && tappedCell != nil {
            
            guard let eventPageVC = segue.destination as? EventPageViewController else { return }
            
            // pass the event to Event Page view.
            eventPageVC.event = self.eventArray[tappedCell!]
            
            // indicate the delegate.
            eventPageVC.updateEventDelegate = self
            
            eventPageVC.navigationItem.title = eventArray[tappedCell!].eventName
            
            // pass the event UID.
            eventPageVC.eventUID = eventArray[tappedCell!].eventUID
        }
    }
    
    // protocol function to update event.
    func updateEvent(withEvent event: Event) {
        
        self.eventArray[tappedCell!] = event
        
    }
    
    func changeEvent(withNewName newName: String, withIndexPath indexPath: IndexPath) {
        
        eventArray[indexPath.row].eventName = newName
        
        self.tableView.reloadRows(at: [indexPath], with: .none)
        
        
        updateEventInRealm(withEventName: newName, withEventUID: eventArray[indexPath.row].eventUID)
    }
    
    // update object with an UID, if it not exists then Realm will create a new object with that UID.
    func updateEventInRealm(withEventName eventName: String, withEventUID uid: String) {
        
        let eventObject = EventObject(withEventName: eventName, withUID: uid)
        
        let realm = try! Realm()
        
        try! realm.write {
            
            realm.add(eventObject, update: true)
        }
        
    }
    
    func queryEventsFromRealm() {
        
        // need to fetch payment, member and event here.
        // I think this might be a overhead, should I use class?
        
        let realm = try! Realm()
        
        // fetch for events.
        let allEvents = realm.objects(EventObject.self)
        
        var count = 0
        
        for event in allEvents {
            
            let newEvent = Event(withName: event.eventName, withUID: event.eventUID)
            
            eventArray.append(newEvent)
            
            let allMembers = realm.objects(MemberObject.self).filter("belongEventUID == '\(event.eventUID)'")
            
            for member in allMembers {
                
                var newMember = Member(withName: member.memberName, withMemberUID: member.memberUID, withEventUID: member.belongEventUID)
                
                let allPayments = realm.objects(PaymentObject.self).filter("belongMemberUID == '\(member.memberUID)'")
                
                for payment in allPayments {
                    
                    newMember.paymentName.append(payment.paymentName)
                    
                    newMember.payment.append(payment.pay)
                    
                    newMember.paymentUID.append(payment.paymentUID)
                }
                
                eventArray[count].memberArray.append(newMember)
            }
            
            count += 1
        }
     
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        
        self.tappedCell = indexPath.row
        
        performSegue(withIdentifier: "toEventPage", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return eventArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! OverviewTableViewCell 
        
        cell.eventName.text = eventArray[indexPath.row].eventName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let changeLString = NSLocalizedString("changeLString", comment: "The change edit action")
        
        let changeEvent = UITableViewRowAction(style: .normal, title: changeLString) { (action, indexPath) in
            
            self.tableView.setEditing(false, animated: true)
            
            let changeEventNameTitleLString = NSLocalizedString("changeEventName", comment: "The title of the change event name alertController.")
            
            let changeEventNameMessageLString = NSLocalizedString("changeEventNameMessage", comment: "The message of change event name alertController.")
            
            let changeEventAlertVC = UIAlertController(title: changeEventNameTitleLString, message: changeEventNameMessageLString, preferredStyle: .alert)
            
            changeEventAlertVC.addTextField(configurationHandler: { (textField: UITextField) in
                
                let newEventNameLString = NSLocalizedString("newEventNameLString", comment: "Placeholder fo the new name.")
                
                textField.placeholder = newEventNameLString
            })
            
            let cancelLString = NSLocalizedString("cancelLString", comment: "The cancel action")
            
            let cancelAction = UIAlertAction(title: cancelLString, style: .cancel, handler: nil)
            
            let doneLString = NSLocalizedString("doneLString", comment: "The done action")
            
            let doneAction = UIAlertAction(title: doneLString, style: .default, handler: { (action) in
                
                let newName = (changeEventAlertVC.textFields?.first)! as UITextField
                
                if newName.text != "" {
                    
                    self.changeEvent(withNewName: newName.text!, withIndexPath: indexPath)
                }
            })
            
            changeEventAlertVC.addAction(cancelAction)
            
            changeEventAlertVC.addAction(doneAction)
            
            self.present(changeEventAlertVC, animated: true, completion: nil)
        }
        
        let deleteLString = NSLocalizedString("deleteLString", comment: "The delete edit action.")
        
        let deleteEvent = UITableViewRowAction(style: .default, title: deleteLString) { (action, indexPath) in
            
            self.tableView.setEditing(false, animated: true)
            
            let deleteEventUID = self.eventArray[indexPath.row].eventUID
            
            self.eventArray.remove(at: indexPath.row)
            
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.endUpdates()
    
            
            // for realm.
            let realm = try! Realm()
            
            let deleteMemberObject = realm.objects(MemberObject.self).filter("belongEventUID == '\(deleteEventUID)'")
            
            for deleteMember in deleteMemberObject {
                
                let deleteMemberUID = deleteMember.memberUID
                
                let deletePaymentObject = realm.objects(PaymentObject.self).filter("belongMemberUID == '\(deleteMemberUID)'")
                
                try! realm.write {
                    
                    realm.delete(deletePaymentObject)
                }
            }
            
            let deleteEventObject = realm.object(ofType: EventObject.self, forPrimaryKey: deleteEventUID)
            
            try! realm.write {
                
                realm.delete(deleteMemberObject)
                
                realm.delete(deleteEventObject!)
            }
        }
        
        return [changeEvent, deleteEvent]
    }
    
}














