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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

//MARK: - Extension
extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// test cell

        let cell = UITableViewCell()
        cell.textLabel?.text = "About"
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: IndexPath.init(row: indexPath.row, section: indexPath.section), animated: true)
    }
    
}