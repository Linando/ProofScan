//
//  ImageAdvancedViewController.swift
//  ProofScan
//
//  Created by Linando Saputra on 02/05/20.
//  Copyright © 2020 Linando Saputra. All rights reserved.
//

import UIKit

class ImageAdvancedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        // Do any additional setup after loading the view.
    }
    

}

extension ImageAdvancedViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCase", for: indexPath) as! MatchCaseCell
            return cell
        }
        else if indexPath.row == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WholeWord", for: indexPath) as! WholeWordCell
            return cell
        }
        else if indexPath.row == 2
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MatchPrefix", for: indexPath) as! MatchPrefixCell
            return cell
        }
        else if indexPath.row == 3
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MatchSuffix", for: indexPath) as! MatchSuffixCell
            return cell
        }
        else if indexPath.row == 4
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IgnorePunctuation", for: indexPath) as! IgnorePunctuationCell
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IgnoreWhiteSpace", for: indexPath) as! IgnoreWhiteSpaceCell
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
}
