//
//  MainViewController.swift
//  Tasker
//
//  Created by viscontti on 04.08.2025.
//

import Foundation
import UIKit

protocol SwitchTableViewCellDelegate {
    func switchDidChangeValue(value: Bool, forIndexPath: IndexPath)
}

class SwitchTableViewCell: UITableViewCell {
    
    var delegate: SwitchTableViewCellDelegate?
    let uiSwitch = UISwitch()
    var thisCellIndexPath: IndexPath?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        uiSwitch.frame = .init(x: 300, y: 6, width: 100, height: 100)
        contentView.addSubview(uiSwitch)
        uiSwitch.addTarget(self, action: #selector(switchDidChangeValue), for: .valueChanged)
    }
    
    @objc private func switchDidChangeValue() {
        if let unwrappedIndexPath = thisCellIndexPath {
            delegate?.switchDidChangeValue(value: uiSwitch.isOn, forIndexPath: unwrappedIndexPath)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchTableViewCellDelegate {
    
    var tasks: [(text: String, IsOn: Bool)] = []
    var tableView: UITableView!
    
    func switchDidChangeValue(value: Bool, forIndexPath: IndexPath) {
        print("value: \(value), indexPath: \(forIndexPath)")
        tasks[forIndexPath.row].IsOn = value
        //saveTasks()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
               tasks.remove(at: indexPath.row)
               tableView.deleteRows(at: [indexPath], with: .fade)
           }
       }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
           return "Delete"
       }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCellSwitch", for: indexPath) as! SwitchTableViewCell
        cell.textLabel?.text = tasks[indexPath.row].text
        cell.thisCellIndexPath = indexPath
        cell.delegate = self
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemMint
        setupAndShowTableView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(showInitialAlert2)
        )
        
    }
    
    func setupAndShowTableView() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "TaskCellSwitch")
        view.addSubview(tableView)
    }
    
    @objc func showInitialAlert2() {
        let alertController = UIAlertController(
            title: "Tasker",
            message: "Write your task",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter your task"
            textField.keyboardType = .default
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            if let taskText = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !taskText.isEmpty{
                print("User entered task: \(taskText)")
                self.tasks.append((text: taskText, IsOn: true))
                self.tableView.reloadData()
            } else {
                self.showInitialAlert(withError: true)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    private func showInitialAlert(withError: Bool) {
        let alertController = UIAlertController(
            title: "Tasker",
            message: "⚠️Empty field⚠️",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
