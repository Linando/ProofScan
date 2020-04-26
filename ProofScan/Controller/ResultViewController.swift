//
//  ResultViewController.swift
//  ProofScan
//
//  Created by Linando Saputra on 21/04/20.
//  Copyright © 2020 Linando Saputra. All rights reserved.
//

import UIKit

class ResultViewController: UITableViewController {

    let cellId = "cellId123123"
    var mistakeTitikStringResult: [String] = []
    var mistakeKomaStringResult: [String] = []
    var mistakeSingkatanStringResult: [String] = []
    
    var mistakeDetailArray = [MistakeDetail()]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.tableFooterView = UIView()
        
        mistakeDetailArray.removeFirst()
//        mistakeSingkatanStringResult.removeFirst()
//        mistakeTitikStringResult.removeFirst()
//        mistakeKomaStringResult.removeFirst()
//        print(mistakeTitikStringResult)
        print(mistakeSingkatanStringResult)
        if mistakeSingkatanStringResult.count != 0
        {
            mistakeDetailArray.append(MistakeDetail(isExpanded: true, mistakeString: mistakeSingkatanStringResult, mistakeType: "Kesalahan kata yang disingkat"))
        }
        if mistakeTitikStringResult.count != 0
        {
            mistakeDetailArray.append(MistakeDetail(isExpanded: true, mistakeString: mistakeTitikStringResult, mistakeType: "Kesalahan penggunaan titik"))
        }
        if mistakeKomaStringResult.count != 0
        {
            mistakeDetailArray.append(MistakeDetail(isExpanded: true, mistakeString: mistakeKomaStringResult, mistakeType: "Kesalahan penggunaan koma"))
        }
        print(mistakeDetailArray.count)
//        navigationItem.title = "Contacts"
//        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let button = UIButton(type: .system)
        button.setTitle(mistakeDetailArray[section].mistakeType, for: .normal)
        button.setTitleColor(.black, for: .normal)
        if mistakeDetailArray[section].mistakeType == "Kesalahan kata yang disingkat"
        {
            button.backgroundColor = .systemRed
        }
        else if mistakeDetailArray[section].mistakeType == "Kesalahan penggunaan titik"
        {
            button.backgroundColor = .systemBlue
        }
        else if mistakeDetailArray[section].mistakeType == "Kesalahan penggunaan koma"
        {
            button.backgroundColor = .systemYellow
        }
        
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        
        button.tag = section
        
        return button
    }
    
    @objc func handleExpandClose(button: UIButton) {
        print("Trying to expand and close section...")
        
        let section = button.tag
        
        // we'll try to close the section first by deleting the rows
        var indexPaths = [IndexPath]()
        for row in mistakeDetailArray[section].mistakeString.indices {
            print(0, row)
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        let isExpanded = mistakeDetailArray[section].isExpanded
        mistakeDetailArray[section].isExpanded = !isExpanded
        
        //button.setTitle(isExpanded ? "Open" : "Close", for: .normal)
        
        if isExpanded {
            tableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView.insertRows(at: indexPaths, with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        print(mistakeDetailArray.count)
        return mistakeDetailArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !mistakeDetailArray[section].isExpanded {
            return 0
        }
        print("numberofrowsinsection")
        return mistakeDetailArray[section].mistakeString.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let name = mistakeDetailArray[indexPath.section].mistakeString[indexPath.row]
        
        cell.textLabel?.text = name
        
        
        return cell
    }

}
