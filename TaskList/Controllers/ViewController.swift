//
//  ViewController.swift
//  TaskList
//
//  Created by BEREZIN Stanislav on 03.10.2020.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Objects
    private var tableView = UITableView()
    private let idCell = "cell"
    
    // MARK: - Data
    private var tasks: [Task] = DataStoreManager.shared.fecthData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: idCell)
        tableView.dataSource = self
        tableView.delegate = self
        placeObjectsOnMainView()
        configureNavigationBar()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(editing, animated: true)
    }
    
    // MARK: - Configuration navigation bar
    private func configureNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let customNavBarAppearance = UINavigationBarAppearance()
        customNavBarAppearance.configureWithOpaqueBackground()
        
        customNavBarAppearance
            .titleTextAttributes = [.foregroundColor: UIColor.white]
        
        customNavBarAppearance
            .largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        customNavBarAppearance.backgroundColor = UIColor(
            red: 21 / 255,
            green: 101 / 255,
            blue: 192 / 255,
            alpha: 194 / 255)
        
        navigationController?.navigationBar
            .standardAppearance = customNavBarAppearance
        
        navigationController?.navigationBar
            .scrollEdgeAppearance = customNavBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func placeObjectsOnMainView() {
        view.addSubview(tableView)
    }
    
    @objc private func addNewTask() {
        showAlert(title: "New Task", message: "Input New Task and press OK") { (text) in
            DataStoreManager.shared.save(data: text)
            self.tasks = DataStoreManager.shared.fecthData()
            self.tableView.reloadData()
        }
    }
}

// MARK: - Alert Controller
extension ViewController {
    
    private func showAlert(title: String?,
                           message: String?,
                           completion: @escaping (String) -> ()) {
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let successAction = UIAlertAction(title: "OK", style: .default) { (_) in
            guard let text = alert.textFields?.first?.text else { return }
            guard text != "" else { return }
            completion(text)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(successAction)
        alert.addAction(cancelAction)
        alert.addTextField { (textField) in
            textField.placeholder = "Place New Task"
        }
        
        present(alert, animated: true)
    }
}

// MARK: - Table View DataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: idCell,
                                                 for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            DataStoreManager.shared.delete(data: task)
            tasks = DataStoreManager.shared.fecthData()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: Table View Delegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(title: "Edit Task", message: "Edit Task and press OK") { (text) in
            DataStoreManager.shared.edit(titleInCurrentTask: text, at: indexPath.row)
            tableView.reloadData()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
