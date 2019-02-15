//
//  ExampleDetailViewController.swift
//  SDOSKeyedCodable_Example
//
//  Created by Antonio Jesús Pallares on 14/02/2019.
//  Copyright © 2019 SDOS. All rights reserved.
//

import UIKit

class ExampleDetailViewController: UIViewController {
    
    fileprivate enum Section: CaseIterable {
        case description
        case json
        case typeToParse
        case mapImplementation
        case decodedObject
        
        func title() -> String {
            switch self {
            case .description:
                return NSLocalizedString("SDOSKeyedCodableExample.type.section.description", comment: "")
            case .json:
                return NSLocalizedString("SDOSKeyedCodableExample.type.section.json", comment: "")
            case .typeToParse:
                return NSLocalizedString("SDOSKeyedCodableExample.type.section.typeToParse", comment: "")
            case .mapImplementation:
                return NSLocalizedString("SDOSKeyedCodableExample.type.section.mapImplementation", comment: "")
            case .decodedObject:
                return NSLocalizedString("SDOSKeyedCodableExample.type.section.decodedObject", comment: "")
            }
        }
        
        func buildSection(example: Example?) -> DetailSection {
            switch self {
            case .description:
                let obj = IndentedObject(indentationLevel: 0, text: example?.detailedDescription)
                return DetailSection(title:title(), objects: [obj])
            case .json:
                let obj = IndentedObject(indentationLevel: 0, text: example?.type.getJSON())
                return DetailSection(title:title(), objects: [obj])
            case .typeToParse:
                let obj = IndentedObject(indentationLevel: 0, text: example?.type.getTypeName())
                return DetailSection(title:title(), objects: [obj])
            case .mapImplementation:
                let obj = IndentedObject(indentationLevel: 0, text: example?.type.getImplementation())
                return DetailSection(title:title(), objects: [obj])
            case .decodedObject:
                var objects = [IndentedObject]()
                if
                    let parsedObjectOpt = try? example?.type.parseJSON(),
                    let parsedObject = parsedObjectOpt {
                    objects = IndentedObject.getPlainListOfIndentedObjects(from: parsedObject)
                    
                }
                return DetailSection(title:title(), objects: objects)
            }
        }
    }
    
    var example: Example? {
        didSet {
            loadData()
            loadStyleWithData()
        }
    }
    
    var arrayModel = [DetailSection]()
    
    fileprivate static let CodeTableViewCellIdentifier = "CodeTableViewCellIdentifier"

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView(frame: .zero)
            tableView.allowsSelection = false
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(UINib(nibName: "CodeTableViewCell", bundle: nil), forCellReuseIdentifier: ExampleDetailViewController.CodeTableViewCellIdentifier)
        }
    }
    
    private func loadData() {
        arrayModel = Section.allCases.map{ $0.buildSection(example: self.example) }
    }
    
    private func loadStyleWithData() {
        title = example?.title
        tableView?.dataSource = self
    }
    
    //MARK: - Actions

}

extension ExampleDetailViewController: UITableViewDataSource {
    
    private static let cellIdentifier = "ExampleDetailCellIdentifier"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayModel[section].objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = arrayModel[indexPath.section].objects[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ExampleDetailViewController.cellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: ExampleDetailViewController.cellIdentifier)
        cell.textLabel?.text = obj.textToShow
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
}


extension ExampleDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return arrayModel[section].title
    }

}
