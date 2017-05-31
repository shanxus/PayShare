//
//  DetailPageViewController.swift
//  PayggyUI
//
//  Created by Shan on 2017/5/27.
//  Copyright © 2017年 ShanStation. All rights reserved.
//

import UIKit

class DetailPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("detailPageTitle", comment: "The navigation item title of detail page")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (event?.memberArray.count)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailPageCell") as! DetailPageTableViewCell
        
        cell.memberName.text = event?.memberArray[indexPath.row].memberName
        
        let memberCount = event?.memberArray.count
        
        let takeLString = NSLocalizedString("TAKELString", comment: "Take money")
        
        let giveLString = NSLocalizedString("GIVELString", comment: "Give money")
        
        cell.relation.text = ( (event?.memberArray[indexPath.row].totalPaid)! - (event?.eventTotalCost)! / memberCount! ) > 0 ? takeLString : giveLString
        
        if cell.relation.text == takeLString {
            
            cell.relation.textColor = UIColor.red
        } else {
            
            cell.relation.textColor = UIColor.black
        }
        
        let memberMoneyRawValue = ((event?.memberArray[indexPath.row].totalPaid)! - (event?.eventTotalCost)! / memberCount! )
        
        let memberMoneyValue = memberMoneyRawValue > 0 ? memberMoneyRawValue : memberMoneyRawValue * -1
        
        cell.value.text = memberMoneyValue.stringValue
        
        return cell
    }
    
}














