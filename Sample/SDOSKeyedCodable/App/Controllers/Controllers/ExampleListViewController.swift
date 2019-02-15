//
//  ExampleListViewController.swift
//  SDOSKeyedCodable_Example
//
//  Created by Antonio Jesús Pallares on 14/02/2019.
//  Copyright © 2019 SDOS. All rights reserved.
//

import UIKit

class ExampleListViewController: UIViewController {
    
    fileprivate static let segueIdentifier = "ShowExampleDetailIdentifier"

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView(frame: .zero)
            tableView.allowsSelection = true
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    lazy private(set) var allExamples: [Example] = {
        return ExampleType.allCases.map{ Example(type: $0) }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Actions
    
    @IBAction func actionDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ExampleListViewController.segueIdentifier {
            guard
                let detail = segue.destination as? ExampleDetailViewController,
                let example = sender as? Example
            else {
                return
            }
            
            detail.example = example
        }
    }

}

extension ExampleListViewController: UITableViewDataSource {
    
    private static let cellIdentifier = "ExampleCellIdentifier"
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allExamples.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let example = allExamples[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ExampleListViewController.cellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: ExampleListViewController.cellIdentifier)
        
        cell.textLabel?.text = example.title
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: cell.textLabel?.font.pointSize ?? 15)
        cell.detailTextLabel?.text = example.description
        cell.detailTextLabel?.numberOfLines = 0
        
        return cell
    }
    
}

extension ExampleListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ExampleListViewController.segueIdentifier, sender: allExamples[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
