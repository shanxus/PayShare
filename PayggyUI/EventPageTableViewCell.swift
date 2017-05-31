//
//  EventPageTableViewCell.swift
//  PayggyUI
//
//  Created by Shan on 2017/5/26.
//  Copyright © 2017年 ShanStation. All rights reserved.
//

import UIKit

class EventPageTableViewCell: UITableViewCell {

    @IBOutlet weak var memberName: UILabel!
    
    @IBOutlet weak var memberPaid: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
