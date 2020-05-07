//
//  SettingViewController.swift
//  ProofScan
//
//  Created by Linando Saputra on 17/04/20.
//  Copyright © 2020 Linando Saputra. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    //MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            ///hilangin footer table
            tableView.tableFooterView = UIView(frame: .zero)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else {
            return
        }
        checkTheme()
    }
    
    func checkTheme() {
        ///chech if theme is dark or light
        switch self.traitCollection.userInterfaceStyle {
        case .light, .unspecified:
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.systemBlue]
            
        case .dark:
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.systemPink]
        default:
            assertionFailure("Unknown Interface")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkTheme()
    }
}

//MARK: - Extension
extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// test cell
        
        if indexPath.row == 0
        {
            //let cell = UITableViewCell()
            //let switchView = UISwitch(frame: .zero)
            
            //cell.textLabel?.text = "Voice feedback"
            //cell.accessoryType = .disclosureIndicator
            
            //switchView.setOn(UserDefaults.standard.bool(forKey: "VoiceFeedback"), animated: false)
            //cell.accessoryView = switchView
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "VoiceFeedback", for: indexPath) as! VoiceFeedbackCell
            
            cell.textLabel?.text = "Voice Feedback"
            
            return cell
        }
        if indexPath.row == 1
        {
//            let cell = UITableViewCell()
//            let switchView = UISwitch(frame: .zero)
//
//            cell.textLabel?.text = "Haptic feedback"
//            cell.accessoryType = .disclosureIndicator
//
//            switchView.setOn(UserDefaults.standard.bool(forKey: "HapticFeedback"), animated: false)
//            cell.accessoryView = switchView
            let cell = tableView.dequeueReusableCell(withIdentifier: "HapticFeedback", for: indexPath) as! HapticFeedbackCell
            
            cell.textLabel?.text = "Haptic Feedback"
            
            return cell
            
        }
        else
        {
            let cell = UITableViewCell()
            
            cell.textLabel?.text = "About"
            cell.accessoryType = .disclosureIndicator
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0
        {
            //UserDefaults.standard.set(UserDefaults.standard.bool(forKey: "VoiceFeedback"), forKey: "VoiceFeedback")
            //print(UserDefaults.standard.bool(forKey: "VoiceFeedback"))
            print("0 selected")
        }
        
        if indexPath.row == 1
        {
            
        }
        
        if indexPath.row == 2
        {
            print("about selected")
            performSegue(withIdentifier: "AboutSegue", sender: self)
//            if let vc = segue.destination as? ResultViewController
//            {
//                vc.mistakeKomaStringResult = komaMistakeString
//                vc.mistakeTitikStringResult = titikMistakeString
//                vc.mistakeSingkatanStringResult = singkatanMistakeString
//            }
        }
        
        tableView.deselectRow(at: IndexPath.init(row: indexPath.row, section: indexPath.section), animated: true)
    }
    
}
