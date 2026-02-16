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
        UIView.animate(withDuration: 0.3, animations: {
                   self.contentView.alpha = 0.5
               }) { _ in
                   UIView.animate(withDuration: 0.3) {
                       self.contentView.alpha = 1.0
                   }
               }
        
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
    
    private var tasksFileURL: URL {
           let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
           return documentsDirectory.appendingPathComponent("tasks.json")
       }
    
    private let lastResetDateKey = "lastResetDate"
    
    private var observers: [NSObjectProtocol] = []
    
    func switchDidChangeValue(value: Bool, forIndexPath: IndexPath) {
        print("value: \(value), indexPath: \(forIndexPath)")
        tasks[forIndexPath.row].IsOn = value
        saveTasks()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.7) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
               tasks.remove(at: indexPath.row)
               tableView.deleteRows(at: [indexPath], with: .fade)
               saveTasks()
           }
       }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
           return "Delete"
       }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCellSwitch", for: indexPath) as! SwitchTableViewCell
        let task = tasks[indexPath.row]
        cell.textLabel?.text = tasks[indexPath.row].text
        cell.thisCellIndexPath = indexPath
        cell.uiSwitch.isOn = task.IsOn
        cell.delegate = self
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray2
        setupAndShowTableView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(showInitialAlert2)
        )
        
        if UserDefaults.standard.object(forKey: lastResetDateKey) == nil {
                UserDefaults.standard.set(Date(), forKey: lastResetDateKey)
                print("📅 First launch - setting initial reset date")
            }
            
        loadTasks()
        observeAppLifecycle()
      
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            resetTasksIfNeeded()
        }
        
    
    deinit {
           // Удаляем observers при уничтожении контроллера
           observers.forEach { NotificationCenter.default.removeObserver($0) }
       }
    
    private func observeAppLifecycle() {
           let token = NotificationCenter.default.addObserver(
               forName: UIApplication.willEnterForegroundNotification,
               object: nil,
               queue: .main
           ) { [weak self] _ in
            self?.resetTasksIfNeeded()
           }
           observers.append(token)
       }
    
    private var isResetAvailable: Bool {
           guard let lastReset = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date else {
               // eсли даты нет - это первый запуск, сброс не нужен
               return false
           }
           // Проверяем, что lastReset был НЕ сегодня
           return !Calendar.current.isDate(lastReset, inSameDayAs: Date())
       }
  
    
    private func resetTasksIfNeeded() {
        guard isResetAvailable else {
                    print("⏰ No need for reset")
                    return
                }
        print ("Need for reset")
           for i in 0..<tasks.count {
               tasks[i].IsOn = false
           }
        // Сохраняем текущую дату как дату последнего сброса
               UserDefaults.standard.set(Date(), forKey: lastResetDateKey)
           
           saveTasks()
           tableView.reloadData()
           showResetNotification()
       }
    
    private func showResetNotification() {
           let alert = UIAlertController(
               title: "🌅 Tasker new day!",
               message: "All the tasks were reset for new day!",
               preferredStyle: .alert
           )
           
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           
           present(alert, animated: true)
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
                self.tasks.append((text: taskText, IsOn: false))
                self.tableView.reloadData()
                self.saveTasks()
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
    
    private func saveTasks() {
           do {
               let tasksArray = tasks.map { ["text": $0.text, "isOn": $0.IsOn] }
               let data = try JSONSerialization.data(withJSONObject: tasksArray, options: .prettyPrinted)
               try data.write(to: tasksFileURL)
               print("Tasks saved successfully to: \(tasksFileURL.path)")
           } catch {
               print("Failed to save tasks: \(error)")
           }
       }
    
    private func loadTasks() {
           do {
               let data = try Data(contentsOf: tasksFileURL)
               if let tasksArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                   tasks = tasksArray.compactMap { dict in
                       guard let text = dict["text"] as? String,
                             let isOn = dict["isOn"] as? Bool else { return nil }
                       return (text: text, IsOn: isOn)
                   }
                   tableView.reloadData()
                   print("Tasks loaded successfully: \(tasks.count) tasks")
               }
           } catch {
               print("Failed to load tasks: \(error)")
           }
       }
}
