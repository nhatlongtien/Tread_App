//
//  SecondViewController.swift
//  Treads
//
//  Created by NGUYENLONGTIEN on 6/7/20.
//  Copyright © 2020 NGUYENLONGTIEN. All rights reserved.
//

import UIKit
import RealmSwift
class MyLogVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    // MARK: - UI Elements
    @IBOutlet weak var tableView: UITableView!
    // MARK: - Models
    var runs:Results<Run>?
    // MARK: - UI ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        runs = Run.getAllRunFromRealm()
        tableView.reloadData()
    }
    // MARK: - UItableView Delegate & datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runs!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: logCell, for: indexPath) as? LogCell {
            cell.configureCell(run: runs![indexPath.row])
            return cell
        }else{
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            //delete object from Realm (Database)
            let selectedRun = runs![indexPath.row]
            Run.deleteRunObjectFromRealm(run: selectedRun) { (success) in
                if success{
                    //delete object from tableView
                    tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                    tableView.reloadData()
                }else{
                    print("Can not delete run")
                }
            }
        }
    }
}

