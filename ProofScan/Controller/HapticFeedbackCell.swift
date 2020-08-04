//
//  HapticFeedbackCell.swift
//  ProofScan
//
//  Created by Ricky Erdiansyah on 08/05/20.
//  Copyright © 2020 Linando Saputra. All rights reserved.
//

import UIKit

class HapticFeedbackCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(UserDefaults.standard.bool(forKey: "HapticFeedback"), animated: false)
        switchView.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        accessoryView = switchView
    }

    @objc func valueChanged(sender: UISwitch) {
        
        UserDefaults.standard.set(sender.isOn, forKey: "HapticFeedback")
        print((textLabel?.text ?? "") + " switch is " + (sender.isOn ? "ON" : "OFF"))
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
