//
//  StatementCellTableViewCell.swift
//  partnershit
//
//  Created by user on 14/10/2017.
//  Copyright © 2017 AnthonyChan. All rights reserved.
//

import UIKit

class StatementCellTableViewCell: UITableViewCell {

    @IBOutlet weak var dateTxt: UILabel!
    @IBOutlet weak var msgTxt: UILabel!
    @IBOutlet weak var priceTxt: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
