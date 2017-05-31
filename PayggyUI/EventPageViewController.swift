//
//  EventPageViewController.swift
//  PayggyUI
//
//  Created by Shan on 2017/5/26.
//  Copyright © 2017年 ShanStation. All rights reserved.
//

import UIKit
import RealmSwift

class EventPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, updateMemebrDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var showDetailBtn: UIButton!
    
    var event: Event?
    
    var updateEventDelegate: updateEventDelegate?
    
    var tappedCell: Int?
    
    var eventUID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let showDetailBtnText = NSLocalizedString("eventPageShowDetailBtn", comment: "The show detail button in Event page")
        
        showDetailBtn.setTitle(showDetailBtnText, for: .normal)

        tableView.dataSource = self
        tableView.delegate = self
        
    }

    @IBAction func addMember(_ sender: Any) {
        
        let addMemberTitle = NSLocalizedString("addMemberTitleLString", comment: "The title of add member alertController")
        
        let addMemberMessage = NSLocalizedString("addMemberMessageLString", comment: "The message of add member alertController")
        
        let addMemberAlertController = UIAlertController(title: addMemberTitle, message: addMemberMessage, preferredStyle: .alert)
        
        addMemberAlertController.addTextField { (textField: UITextField!) in
            
            let newMemberNamePlaceholder = NSLocalizedString("newMemberNamePlaceholderLString", comment: "The placeholder of new member name")
            
            textField.placeholder = newMemberNamePlaceholder
            
        }
        
        let cancelLString = NSLocalizedString("cancelLString", comment: "The cancel action")
        
        let cancelAction = UIAlertAction(title: cancelLString, style: .cancel, handler: nil)
        
        addMemberAlertController.addAction(cancelAction)
        
        let addLString = NSLocalizedString("addLString", comment: "The add action")
        
        let addMemberAction = UIAlertAction(title: addLString, style: .default) { (action: UIAlertAction) in
            
            guard let memberName = addMemberAlertController.textFields?.first!.text else { return }
            
            self.addMember(withMemberName: memberName)
        }
        
        addMemberAlertController.addAction(addMemberAction)
        
        self.present(addMemberAlertController, animated: true, completion: nil)
        
    }
    
    func addMember(withMemberName memberName: String) {
        
        let newMemberUID = UUID().uuidString
        
        let newMember = Member(withName: memberName, withMemberUID: newMemberUID, withEventUID: eventUID!)
        
        event?.memberArray.append(newMember)
        
        self.tableView.reloadData()
        
        // issue: run this in another thread?
        // update event in Overview Page by delegate method.
        updateEventDelegate?.updateEvent(withEvent: self.event!)
        
        updateMemberInRealm(withMemberName: memberName, memberUID: newMemberUID, belongTo: eventUID!)
        
    }
    
    @IBAction func showDetailWasTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "toDetailPage", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toMemberPaymentPage" {
            
            let memberPaymentPageVC = segue.destination as! MemberPaymentPageViewController
            
            memberPaymentPageVC.member = self.event?.memberArray[tappedCell!]
            
            memberPaymentPageVC.updateMemberDelegate = self
            
            memberPaymentPageVC.navigationItem.title = self.event?.memberArray[tappedCell!].memberName
            
            memberPaymentPageVC.memberUID = self.event?.memberArray[tappedCell!].memberUID
            
        } else if segue.identifier == "toDetailPage" {
            
            let detailPageVC = segue.destination as! DetailPageViewController
            
            detailPageVC.event = self.event!
            
        }
    }
    
    // protocol function to update member state.
    func updateMember(withMember member: Member) {
        
        self.event?.memberArray[tappedCell!] = member
        
        self.tableView.reloadData()
        
        // update event state.
        updateEventDelegate?.updateEvent(withEvent: self.event!)
        
    }
    
    func changeMember(withNewName newName: String, withIndexPath indexPath: IndexPath) {
     
        event?.memberArray[indexPath.row].memberName = newName
        
        self.tableView.reloadRows(at: [indexPath], with: .none)
        
        updateEventDelegate?.updateEvent(withEvent: event!)
        
        updateMemberInRealm(withMemberName: newName, memberUID: (event?.memberArray[indexPath.row].memberUID)!, belongTo: eventUID!)
    }
    
    func updateMemberInRealm(withMemberName memberName: String, memberUID UID: String, belongTo eventUID: String) {
     
        let memberObject = MemberObject(withMemberName: memberName, memberUID: UID, belongTo: eventUID)
        
        let realm = try! Realm()
        
        try! realm.write {
        
            realm.add(memberObject, update: true)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (event?.memberArray.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell") as! EventPageTableViewCell
        
        cell.memberName.text = event?.memberArray[indexPath.row].memberName
        
        cell.memberPaid.text = event?.memberArray[indexPath.row].totalPaid.stringValue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        
        self.tappedCell = indexPath.row
        
        performSegue(withIdentifier: "toMemberPaymentPage", sender: self)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let changeLString = NSLocalizedString("changeLString", comment: "The change edit action")
        
        let changeMember = UITableViewRowAction(style: .normal, title: changeLString) { (action, indexPath) in
            
            self.tableView.setEditing(false, animated: true)
            
            let changeNameTitle = NSLocalizedString("changeNameTitle", comment: "The title of change member name alterController.")
            
            let changeNameMessage = NSLocalizedString("changeNameMessage", comment: "The message of change member name alertController.")
            
            let changeAlertVC = UIAlertController(title: changeNameTitle, message: changeNameMessage, preferredStyle: .alert)
            
            changeAlertVC.addTextField(configurationHandler: { (textField: UITextField) in
                
                let newMemberName = NSLocalizedString("newMemberNamePlaceholder", comment: "The placeholder of the new member name.")
                
                textField.placeholder = newMemberName
            })
            
            let cancelLString = NSLocalizedString("cancelLString", comment: "The cancel action")
            
            let cancelAction = UIAlertAction(title: cancelLString, style: .cancel, handler: nil)
            
            let doneLString = NSLocalizedString("doneLString", comment: "The done action")
            
            let doneAction = UIAlertAction(title: doneLString, style: .default, handler: { (action) in
                
                let newEventName = (changeAlertVC.textFields?.first)! as UITextField
                
                if newEventName.text != "" {
                    
                    self.changeMember(withNewName: newEventName.text!, withIndexPath: indexPath)
                }
            })
            
            changeAlertVC.addAction(cancelAction)
            
            changeAlertVC.addAction(doneAction)
            
            self.present(changeAlertVC, animated: true, completion: nil)
        }
        
        let deleteLString = NSLocalizedString("deleteLString", comment: "The delete edit action.")
        
        let deleteMember = UITableViewRowAction(style: .default, title: deleteLString) { (action, indexPath) in
            
            self.tableView.setEditing(false, animated: true)
            
            let deleteMemberUID = self.event?.memberArray[indexPath.row].memberUID
            
            self.event?.memberArray.remove(at: indexPath.row)
            
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.endUpdates()
            
            self.updateEventDelegate?.updateEvent(withEvent: self.event!)
            
            
            // for realm.
            
            let realm = try! Realm()
            
            let allPaymentsShouldBeDelete = realm.objects(PaymentObject.self).filter("belongMemberUID == '\(deleteMemberUID!)'")
            
            let deleteMemberObject = realm.object(ofType: MemberObject.self, forPrimaryKey: deleteMemberUID)
            
            try! realm.write {
                
                realm.delete(allPaymentsShouldBeDelete)
                
                realm.delete(deleteMemberObject!)
            }
            
        }
        
        return [changeMember, deleteMember]
    }
    
    
}


















