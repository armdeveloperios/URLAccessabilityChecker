//
//  ViewController.swift
//  AccessibilityURLs
//
//  Created by Armen Alikhanyan on 3/21/19.
//  Copyright © 2019 Armen Alikhanyan. All rights reserved.
//

import UIKit

enum SortType: Int {
    case degreeByAlphafit
    case declineByAlphafit
    case accessibilityToFailure
    case failureToAccessibility
    case degreeByResponseTime
    case declineByResponseTime
    
    case unknown
}

class RootViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rightButtonItem: UIBarButtonItem!
    @IBOutlet weak var leftButtonItem: UIBarButtonItem!
    @IBOutlet weak var refreshButtonItem: UIBarButtonItem!
    @IBOutlet weak var sortButtonItem: UIBarButtonItem!
    
    // MARK: - Properties
    var urlChecker = URLChecker()
    var urls: [URLModel] = []
    var filteredUrls = [URLModel]()
    var searchController: UISearchController!
    var isSelectEdit = false
    var sortType: SortType = .unknown
    var isSelectAdd = false {
        didSet {
            if oldValue {
                leftButtonItem.title = edit
                rightButtonItem.title = add
            } else {
                leftButtonItem.title = cancel
                rightButtonItem.title = save
            }
        }
    }
    
    var refreshCount: Int = 0 {
        didSet {
            if oldValue == urls.count {
                sort(by: sortType)
                refreshCount = 0
            }
        }
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        urls = CoreDataManager.shared.getModels()
        setupSearchController()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private API
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("notification: Keyboard will show")
            if self.view.frame.origin.y == 0 {
                self.tableView.contentInset.bottom = keyboardSize.height
            }
        }
        
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        self.tableView.contentInset.bottom = 0
    }

    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search URL"
        definesPresentationContext = true
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
        } else {
            self.tableView.tableHeaderView = searchController.searchBar
        }
    }
    
    private func index(of url: String) -> Int {
        for (index, model) in urls.enumerated() {
            if model.urlString == url && model.urlType == .loading {
                return index
            }
        }
        return Int.max
    }
    
    private func sortDegreeByAlphafit() {
        urls = urls.sorted {$0.urlString.localizedCaseInsensitiveCompare($1.urlString) == .orderedAscending}
    }
    
    private func sortDeclineByAlphafit() {
        urls = urls.sorted {$0.urlString.localizedCaseInsensitiveCompare($1.urlString) == .orderedDescending}
    }
    
    private func sortAccessibilityToFailure() {
        urls = urls.sorted(by: {$0.urlType.rawValue < $1.urlType.rawValue})
    }
    
    private func sortFailureToAccessibility() {
        urls = urls.sorted(by: {$0.urlType.rawValue > $1.urlType.rawValue})
    }

    private func sortDegreeByResponseTime() {
        urls = urls.sorted(by: {$0.duringTime < $1.duringTime})
    }
    
    private func sortDeclineByResponseTime() {
        urls = urls.sorted(by: {$0.duringTime > $1.duringTime})
    }
    
    private func sort(by type: SortType) {
        switch type {
        case .degreeByAlphafit:
            sortDegreeByAlphafit()
        case .declineByAlphafit:
            sortDeclineByAlphafit()
        case .accessibilityToFailure:
            sortAccessibilityToFailure()
        case .failureToAccessibility:
            sortFailureToAccessibility()
        case .degreeByResponseTime:
            sortDegreeByResponseTime()
        case .declineByResponseTime:
            sortDeclineByResponseTime()
        default:
            return
        }
        reloadData()
    }

    private func reloadData() {
        if Thread.current.isMainThread {
            tableView.reloadData()
        } else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredUrls = urls.filter({( model : URLModel) -> Bool in
            return model.urlString.lowercased().hasPrefix(searchText.lowercased())
        })
        
        reloadData()
    }

    private func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    private func refreshModel(at index: Int, _ type: URLType, _ time: Double) {
        urls[index].duringTime = time
        urls[index].urlType = type
        CoreDataManager.shared.update(model: urls[index])
    }
    
    // MARK: - Actions
    
    @IBAction func addOrSaveAction(_ sender: UIBarButtonItem) {
        isSelectAdd = !isSelectAdd
        if !isSelectAdd {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddURLTableViewCell, let url = cell.urlTextField.text  {
                let textWithoutWhitespace = url.replacingOccurrences(of: " ", with: "")
                if textWithoutWhitespace.count == 0 {
                    self.showAler(title: "Warning!", message: "Url can not empty.", okAction: nil)
                } else {
                    urlChecker.check(urlString: url) { [unowned self] (type, time) in
                        DispatchQueue.global().async {
                            let index = self.index(of: url)
                            if index != Int.max {
                                self.urls[index].urlType = type
                                self.urls[index].duringTime = time
                                CoreDataManager.shared.add(model: self.urls[index])
                                self.reloadData()
                            }
                        }
                    }
                    let model = URLModel(url, .loading, 0)
                    urls.insert(model, at: 0)
                    reloadData()
                }
            }
            refreshButtonItem.isEnabled = true
            sortButtonItem.isEnabled = true
        } else {
            refreshButtonItem.isEnabled = false
            sortButtonItem.isEnabled = false
        }
        reloadData()
    }
    
    @IBAction func refreshAction(_ sender: UIBarButtonItem) {
        for (index, model) in urls.enumerated() {
            model.urlType = .loading
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.urlChecker.check(urlString: model.urlString, atIndex: index) { [weak self] (type, time, index) in
                
                self?.refreshModel(at: index, type, time)
                DispatchQueue.main.async {
                    self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    self?.refreshCount += 1
                }
            }
        }
    }
    
    @IBAction func editOrCancelAction(_ sender: UIBarButtonItem) {
        if isSelectAdd && !isSelectEdit {
            sender.title = edit
            self.view.endEditing(true)
            refreshButtonItem.isEnabled = true
            sortButtonItem.isEnabled = true
            isSelectAdd = !isSelectAdd
            reloadData()
        } else if !isSelectAdd && !isSelectEdit {
            sender.title = cancel
            rightButtonItem.isEnabled = false
            refreshButtonItem.isEnabled = false
            sortButtonItem.isEnabled = false
            isSelectEdit = !isSelectEdit
            self.tableView.setEditing(true, animated: true)
        } else if isSelectEdit {
            sender.title = edit
            isSelectEdit = !isSelectEdit
            rightButtonItem.isEnabled = true
            refreshButtonItem.isEnabled = true
            sortButtonItem.isEnabled = true
            self.tableView.setEditing(false, animated: true)
        }
    }
    
    @IBAction func sortAction(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "Choose sort type.", message: nil, preferredStyle: .actionSheet)
        
        let degreeByAlphafit = UIAlertAction(title: "DegreeByAlphafit", style: .default) { (action) in
            self.sortType = .degreeByAlphafit
            self.sort(by: .degreeByAlphafit)
        }
        
        let declineByAlphafit = UIAlertAction(title: "DeclineByAlphafit", style: .default) { (action) in
            self.sortType = .declineByAlphafit
            self.sort(by: .declineByAlphafit)
        }
        
        let accessibilityToFailure = UIAlertAction(title: "Accessibility To Failure", style: .default) { (action) in
            self.sortType = .accessibilityToFailure
            self.sort(by: .accessibilityToFailure)
        }
        
        let failureToAccessibility = UIAlertAction(title: "Failure To Accessibility", style: .default) { (action) in
            self.sortType = .failureToAccessibility
            self.sort(by: .failureToAccessibility)
        }
        
        let degreeByResponseTime = UIAlertAction(title: "Degree By Response Time", style: .default) { (action) in
            self.sortType = .degreeByResponseTime
            self.sort(by: .degreeByResponseTime)
        }
        
        let declineByResponseTime = UIAlertAction(title: "Decline By Response Time", style: .default) { (action) in
            self.sortType = .declineByResponseTime
            self.sort(by: .declineByResponseTime)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(degreeByAlphafit)
        actionSheet.addAction(declineByAlphafit)
        actionSheet.addAction(accessibilityToFailure)
        actionSheet.addAction(failureToAccessibility)
        actionSheet.addAction(degreeByResponseTime)
        actionSheet.addAction(declineByResponseTime)
        actionSheet.addAction(cancel)
        
        
        if UIDevice.isIphone() {
            self.present(actionSheet, animated: true, completion: nil)
        } else {
            if let currentPopoverpresentioncontroller = actionSheet.popoverPresentationController {
                currentPopoverpresentioncontroller.barButtonItem = sender
                self.present(actionSheet, animated: true, completion: nil)
            }
        }
    }
}

extension RootViewController: UITableViewDataSource {
    // MARK: UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering() ? filteredUrls.count : isSelectAdd ? 1 : urls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = isFiltering() ? filteredUrls : urls
        if isSelectAdd {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddURLTableViewCell.reuseIdentifier, for: indexPath) as? AddURLTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            return cell
        } else {
            let model = data[indexPath.row]
            
            if model.urlType == .loading {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: LoadingCell.reuseIdentifier, for: indexPath) as? LoadingCell else {
                    return UITableViewCell()
                }
                cell.configure(model)
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: URLTableViewCell.reuseIdentifier, for: indexPath) as? URLTableViewCell else {
                    return UITableViewCell()
                }
                cell.configure(model)
                return cell
            }
        }
    }
}

extension RootViewController: UITableViewDelegate {
    // MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let model = urls[indexPath.row]
            if model.urlType == .loading {
                self.showAler(title: "Warning!", message: "You can not delate loading cell.", okAction: nil)
            } else {
                CoreDataManager.shared.delate(model: model)
                urls.remove(at: indexPath.row)
                reloadData()
            }
        }
    }
    
}

extension RootViewController: AddURLTableViewCellDelegate {
    // MARK: AddURLTableViewCell Delegate
    func addURLTableViewCellDidEndEditing(_ cell: AddURLTableViewCell) -> Bool {
        return cell.urlTextField.resignFirstResponder()
    }
}

extension RootViewController: UISearchResultsUpdating {
    // MARK: UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            filterContentForSearchText(text)
        }
    }
}
