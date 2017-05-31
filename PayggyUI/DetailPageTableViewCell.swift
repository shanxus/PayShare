//
//  DetailPageTableViewCell.swift
//  PayggyUI
//
//  Created by Shan on 2017/5/27.
//  Copyright © 2017年 ShanStation. All rights reserved.
//

import UIKit

class DetailPageTableViewCell: UITableViewCell {

    
    @IBOutlet weak var memberName: UILabel!
    
    @IBOutlet weak var relation: UILabel!
    
    @IBOutlet weak var value: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
