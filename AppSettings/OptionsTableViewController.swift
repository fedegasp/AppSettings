//
//  OptionsTableViewController.swift
//  AppSettings
//
//  Created by Federico Gasperini on 18/03/2021.
//

import UIKit

class OptionsTableViewController: UITableViewController {
    
    var setting: Setting?
    
    var currentIndex: Int? {
        if let t = self.setting?.currentValueTitle {
            return self.setting?.titles?.firstIndex(of: t)
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.setting?.values?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "option", for: indexPath)
        
        cell.textLabel?.text = setting?.titles?[indexPath.row]
        if let index = self.currentIndex,
           indexPath.row == index {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let newValue = self.setting?.values?[indexPath.row] else { return nil }
        tableView.performBatchUpdates {
            var indexes = [indexPath]
            if let currentIndex = self.currentIndex {
                indexes.append(IndexPath(row: currentIndex, section: 0))
            }
            self.setting?.value = newValue
            tableView.reloadRows(at: indexes, with: .none)
        }
        return indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
