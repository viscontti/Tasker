//
//  MainViewController.swift
//  Tasker
//
//  Created by viscontti on 04.08.2025.
//

import Foundation
import UIKit

protocol UITableDelegate{
    func cellInTableTapped()
}

class UiSwitchTable: UITableViewCell {
    
    let uiSwitch = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        uiSwitch.frame = .init(x: 300, y: 6, width: 100, height: 100)
        contentView.addSubview(uiSwitch)
        uiSwitch.addTarget(self, action: #selector(switchDidChangeValue), for: .valueChanged)
    }
    
    @objc private func switchDidChangeValue() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tasks: [String] = []
    var tableView: UITableView!
    var delegate: UITableDelegate?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCellSwitch", for: indexPath) as! UiSwitchTable
        //cell.uiSwitch.isOn = cacheArray[indexPath.row]
        cell.textLabel?.text = String("\(indexPath)")
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemMint
        setupAndShowTableView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(setupAndShowTableView)
        )
        
    }
    
    @objc func setupAndShowTableView() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.register(UiSwitchTable.self, forCellReuseIdentifier: "TaskCellSwitch")
        view.addSubview(tableView)
    }
    
    func showInitialAlert() {
        let alertController = UIAlertController(
            title: "Tasker",
            message: "Write your first task",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter your task"
            textField.keyboardType = .default
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            if let taskText = alertController.textFields?.first?.text {
                print("User entered task: \(taskText)")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
