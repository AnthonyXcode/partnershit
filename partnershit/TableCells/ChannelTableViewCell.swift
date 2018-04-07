//
//  ChannelTableViewCell.swift
//  partnershit
//
//  Created by user on 3/4/2018.
//  Copyright © 2018 AnthonyChan. All rights reserved.
//

import UIKit
import SwiftMessages

class ChannelTableViewCell: UITableViewCell {

    @IBOutlet var channelName: UILabel!
    @IBOutlet weak var channelCodeBtn: UIButton!
    @IBAction func channelCodeBtn(_ sender: Any) {
        UIPasteboard.general.string = self.channelCodeBtn.currentTitle
        self.showCopyDialog(code: self.channelCodeBtn.currentTitle as! String)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showCopyDialog(code: String) {
        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        config.duration = .seconds(seconds: 2)
        let view = MessageView.viewFromNib(layout: .messageView)
        view.configureTheme(.info)
        view.titleLabel?.isHidden = true
        view.button?.isHidden = true
        view.iconLabel?.isHidden = true
        view.iconImageView?.isHidden = true
        view.configureContent(body: "已複製 " + code)
        view.bodyLabel?.textColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        SwiftMessages.show(config: config, view: view)
    }

}
