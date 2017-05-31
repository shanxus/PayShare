//
//  MemberPaymentPageViewController.swift
//  PayggyUI
//
//  Created by Shan on 2017/5/27.
//  Copyright © 2017年 ShanStation. All rights reserved.
//

import UIKit
import RealmSwift

class MemberPaymentPageViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addPayBtn: UIButton!
    
    var member: Member?
    
    var updateMemberDelegate: updateMemebrDelegate?
    
    var memberUID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let addPaymentBtnText = NSLocalizedString("paymentPageAddBtn", comment: "The add payment button in Member Payment Page.")
        
        addPayBtn.setTitle(addPaymentBtnText, for: .normal)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
    }
    
    @IBAction func addWasTapped(_ sender: Any) {
        
        let addPaymentTitle = NSLocalizedString("addPaymentTitle", comment: "The title of the add payment alertController.")
        
        let addPaymentMessage = NSLocalizedString("addPaymentMessage", comment: "The message of the add payment alertController.")
        
        let addPaymemntAlertVC = UIAlertController(title: addPaymentTitle, message: addPaymentMessage, preferredStyle: .alert)
        
        addPaymemntAlertVC.addTextField { (textField: UITextField) in
            
            let paymentNamePlaceholder = NSLocalizedString("addPaymentNamePlaceholder", comment: "The name placeholder of the add paymemnt alertController.")
            
            textField.placeholder = paymentNamePlaceholder
        }
        
        addPaymemntAlertVC.addTextField { (textField: UITextField) in
            
            let paymentValuePlaceholder = NSLocalizedString("addPaymentValuePlaceholder", comment: "The value placeholder of the add paymemnt alertController.")
            
            textField.placeholder = paymentValuePlaceholder
            textField.keyboardType = .numberPad
        }
        
        let cancelLString = NSLocalizedString("cancelLString", comment: "The cancel action")
        
        let cancel = UIAlertAction(title: cancelLString, style: .cancel, handler: nil)
        
        let addLString = NSLocalizedString("addLString", comment: "The add action")
        
        let addAction = UIAlertAction(title: addLString, style: .default) { (action) in
            
            let paymentName = (addPaymemntAlertVC.textFields?.first)! as UITextField
            
            let pay = (addPaymemntAlertVC.textFields?.last)! as UITextField
            
            // check for valid input.
            if paymentName.text != "" && pay.text != "" {
                
                //self.member?.payment.append(Int(pay.text!)!)
                self.addPayment(withPayName: paymentName.text!, withPay: pay.text!)
                
            }
        }
        
        addPaymemntAlertVC.addAction(cancel)
        
        addPaymemntAlertVC.addAction(addAction)
        
        self.present(addPaymemntAlertVC, animated: true, completion: nil)
    }
    
    func addPayment(withPayName payName: String, withPay pay: String) {
        
        let newPaymentUID = UUID().uuidString
        
        self.member?.paymentName.append(payName)
        
        self.member?.payment.append(Int(pay)!)
        
        self.member?.paymentUID.append(newPaymentUID)
        
        // maybe using tableView.insert here to get better performance?
        self.tableView.reloadData()
        
        updateMemberDelegate?.updateMember(withMember: self.member!)
        
        
        // for realm.
        updatePaymentInRealm(withPaymentName: payName, withPay: Int(pay)!, withPaymentUID: newPaymentUID, belongTO: memberUID!)
    }
    
    func changePayment(withNamePaymentName newName: String, withNewPay newPay: String, withIndex index: IndexPath) {
        
        self.member?.paymentName[index.row] = newName
        
        self.member?.payment[index.row] = Int(newPay)!
        
        self.tableView.reloadRows(at: [index], with: .none)
        
        updateMemberDelegate?.updateMember(withMember: self.member!)
        
        // for realm.
        let paymentUID = self.member?.paymentUID[index.row]
        
        updatePaymentInRealm(withPaymentName: newName, withPay: Int(newPay)!, withPaymentUID: paymentUID!, belongTO: memberUID!)
        
    }
    
    func updatePaymentInRealm(withPaymentName name: String, withPay pay: Int, withPaymentUID UID: String, belongTO memberUID: String) {
        
        let paymentObject = PaymentObject(withPaymentName: name, withPay: pay, paymentUID: UID, belongTO: memberUID)
        
        let realm = try! Realm()
        
        try! realm.write {
            
            realm.add(paymentObject, update: true)
        }
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (member?.payment.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberPaymentCell") as! MemberPaymentPageTableViewCell
        
        cell.paymentName.text = member?.paymentName[indexPath.row]
        
        // test whether this work.
        cell.pay.text = member?.payment[indexPath.row].stringValue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }
    
    // add new edit action for row.
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let changeLString = NSLocalizedString("changeLString", comment: "The change edit action")
        
        let changePayment = UITableViewRowAction(style: .normal, title: changeLString) { (change, indexPath) in
            
            // to let the row moving back.
            self.tableView.setEditing(false, animated: true)
            
            let changePaymentTitle = NSLocalizedString("changePaymentTitle", comment: "The title of the change payment alertController")
            
            let changePaymentMessage = NSLocalizedString("changePaymentMessage", comment: "The message of the change payment alertController")
            
            let changeAlertVC = UIAlertController(title: changePaymentTitle, message: changePaymentMessage, preferredStyle: .alert)
            
            changeAlertVC.addTextField(configurationHandler: { (textField: UITextField) in
                
                let newPaymentName = NSLocalizedString("newPaymentNamePlaceholder", comment: "The placeholder of the new payment name.")
                
                textField.placeholder = newPaymentName
            })
            
            changeAlertVC.addTextField(configurationHandler: { (textField: UITextField) in
                
                let newPaymentValue = NSLocalizedString("newPaymentValuePlaceholder", comment: "The placeholder of the new payment value.")
                
                textField.placeholder = newPaymentValue
                textField.keyboardType = .numberPad
            })
            
            let cancelLString = NSLocalizedString("cancelLString", comment: "The cancel action")
            
            let cancelAction = UIAlertAction(title: cancelLString, style: .cancel, handler: nil)
            
            let doneLString = NSLocalizedString("doneLString", comment: "The done action")
            
            let doneAction = UIAlertAction(title: doneLString, style: .default, handler: { (action) in
                
                let newPaymentName = (changeAlertVC.textFields?.first)! as UITextField
                
                let newPay = (changeAlertVC.textFields?.last)! as UITextField
                
                if newPaymentName.text != "" && newPay.text != "" {
                    
                    self.changePayment(withNamePaymentName: newPaymentName.text!, withNewPay: newPay.text!, withIndex: indexPath)
                }
                
            })
            
            changeAlertVC.addAction(cancelAction)
            changeAlertVC.addAction(doneAction)
            
            self.present(changeAlertVC, animated: true, completion: nil)
            
        }
        
        let deleteLString = NSLocalizedString("deleteLString", comment: "The delete edit action.")
        
        let deletePayment = UITableViewRowAction(style: .default, title: "Delete") { (delete, indexPath) in
            
            self.tableView.setEditing(false, animated: true)
            
            let deletePaymentUID = self.member?.paymentUID[indexPath.row]
            
            self.member?.payment.remove(at: indexPath.row)
            self.member?.paymentName.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            
            self.updateMemberDelegate?.updateMember(withMember: self.member!)
            
            
            // for realm delete.
            let realm = try! Realm()
            
            let deleteObject = realm.object(ofType: PaymentObject.self, forPrimaryKey: deletePaymentUID)
            
            try! realm.write {
                
                realm.delete(deleteObject!)
            }
        }
        
        return [changePayment, deletePayment]
    }
}

extension Int {
    
    var stringValue: String {
        
        return "\(self)"
    }
}








