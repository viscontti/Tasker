//
//  TaskListViewController.swift
//  Tasker
//
//  Created by viscontti on 10.08.2025.
//

import UIKit

class TaskListViewController : UIViewController, UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    var tasks: [String] = []
    var tableView = UITableView()
    
    
    
}
