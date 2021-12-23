//
//  ListCtrlr.swift
//  MediaCaptureTutorial
//
//  Created by cp3hnu on 2021/12/23.
//

import UIKit

final class ListCtrlr: UIViewController {

    private let identifier = "cell"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "功能列表"
        self.view.backgroundColor = UIColor.white

        let tableView = UITableView()
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .singleLine
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
}

// MARK: - UITableViewDataSource
extension ListCtrlr: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        switch indexPath.row {
            case 0:
                cell.textLabel?.text = "扫码"
            default:
                cell.textLabel?.text = "提取视频帧"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var ctrlr: UIViewController!
        switch indexPath.row {
            case 0:
                ctrlr = ScanCodeCtrlr()
            default:
                ctrlr = FrameExtractionCtrlr()
        }
        
        self.navigationController?.pushViewController(ctrlr, animated: true)
    }
}
