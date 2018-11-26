//
// TrashOut
// Copyright 2017 TrashOut NGO. All rights reserved.
// License GNU GPLv3
//

/**
  * TrashOut is an environmental project that teaches people how to recycle
  * and showcases the worst way of handling waste - illegal dumping. All you need is a smart phone.
  *
  *
  * There are 10 types of programmers - those who are helping TrashOut and those who are not.
  * Clean up our code, so we can clean up our planet.
  * Get in touch with us: help@trashout.ngo
  *
  * Copyright 2017 TrashOut, n.f.
  *
  * This file is part of the TrashOut project.
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 3 of the License, or
  * (at your option) any later version.
  *
  * This program is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
  * See the GNU General Public License for more details: <https://www.gnu.org/licenses/>.
 */

import UIKit

class JunkyardFiltViewController: ViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var lblDisplay: UILabel!
    @IBOutlet var lblDisplayTypes: UILabel!
    //@IBOutlet var pickerView: UIPickerView!
	@IBOutlet var tfDisplay: UITextField!

	var pickerView: UIPickerView!

    var junkyards: [Junkyard] = [] {
        didSet {
            ShowFilterDataDelegate?.showFilterData(value: junkyards)
            if junkyards.isEmpty {
                show(message: "global.filter.noResult".localized)
            } else {
                SendDataForJunkyardFilterDelegate?.sendDataForJunkyardFilter(size: size?.rawValue ?? "all", type: filterTypes)
                navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }

    var ShowFilterDataDelegate: ShowFilterData? = nil
    var SendDataForJunkyardFilterDelegate: SendDataForJunkyardFilter? = nil
    
    fileprivate var types: [Junkyard.JunkyardType]!
    fileprivate var dustbinTypes: [Junkyard.DustbinType]!
    //fileprivate var sizes: [String]!
    //fileprivate var filterSize: String!
	fileprivate var size: Junkyard.Category?
    fileprivate var filterTypes = [String]()
    fileprivate var unselectedSwitchers = [Int]()
    fileprivate let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "collectionPoint.filter.header".localized

        let cancelButton = UIBarButtonItem(title: "global.cancel".localized, style: .plain, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = cancelButton
        let filterButton = UIBarButtonItem(title: "global.filter".localized, style: .plain, target: self, action: #selector(filterJunkyards))
        navigationItem.rightBarButtonItem = filterButton

        lblDisplay.text = "collectionPoint.filter.size".localized
        lblDisplay.font = Theme.current.font.boldText
        lblDisplay.textColor = Theme.current.color.green
        lblDisplayTypes.text = "collectionPoint.filter.types".localized
        lblDisplayTypes.font = Theme.current.font.boldText
        lblDisplayTypes.textColor = Theme.current.color.green

        /// Initial setup
		types = Junkyard.JunkyardType.allValues.filter({$0 != .undefined})
        dustbinTypes = Junkyard.DustbinType.allValues.filter({$0 != .undefined})

        /// If saved load filter types
        if let filterType = defaults.object(forKey: "FilterTypes") as? [String] {
			filterTypes = filterType
        } else {
			filterTypes = types.map({$0.rawValue})
        }

        /// If saved load which switcher are unselected
        if let unselected = defaults.object(forKey: "UnselectedSwitchers") as? [Int] {
            unselectedSwitchers = unselected
        } else {
            // Inital setup for switchers is unslected
            for i in 0...types.count - 1 {
                unselectedSwitchers.append(i)
                defaults.set(unselectedSwitchers, forKey: "UnselectedSwitchers")
            }
        }
        
		self.setupDisplaySelect()
    }

    /*
    Go back to junkyards list
    */
    @objc func cancel() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    /*
    Go back to junkyards list when filter is loaded
    */
    @objc func filterJunkyards() {
        LoadingView.show(on: self.view, style: .transparent)

        let locationPoint = LocationManager.manager.currentLocation.coordinate
		
        Networking.instance.junkyards(position: locationPoint, size: size?.rawValue ?? "all", type: filterTypes, page: 1) { [weak self] (junkyards, error) in
			LoadingView.hide()
            guard error == nil else {
                print(error?.localizedDescription as Any)
                self?.show(message: "Can not load data, please try it again later")
                return
            }
            guard let newJunkyards = junkyards else { return }
            self?.junkyards += newJunkyards
        }
    }


	func setupDisplaySelect() {
		pickerView = UIPickerView()
		pickerView.dataSource = self
		pickerView.delegate = self
		tfDisplay.inputView = pickerView
		tfDisplay.delegate = self
		tfDisplay.font = Theme.current.font.text

		let doneButton = UIBarButtonItem.init(title: "global.done".localized, style: .done, target: self, action: #selector(didSelectDisplay))
		let toolbar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
		toolbar.items = [UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton]
		toolbar.barStyle = .default
		toolbar.sizeToFit()
		tfDisplay.inputAccessoryView = toolbar

		/// If saved load filter size
		if let filtSize = defaults.object(forKey: "FilterSize") as? String {
			size = Junkyard.Category(rawValue: filtSize)
		} else {
			size = nil
		}

		/// If saved show witch row was last selected
		if let row = defaults.object(forKey: "Row") as? Int {
			pickerView.selectRow(row, inComponent: 0, animated: false)
		} else {
			pickerView.selectRow(0, inComponent: 0, animated: false) // All
		}
		tfDisplay.text = self.size?.localizedName ?? "collectionPoint.size.all".localized
	}

	@objc func didSelectDisplay() {
		tfDisplay.resignFirstResponder()
	}

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if textField == tfDisplay { // enable editing using only pickerview
			return false
		}
		return true
	}


    // MARK: - Table view Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return types.count
        default:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectAllCell", for: indexPath) as? SelectAllTableViewCell else { fatalError("Could not dequeue cell with identifier: SelectAllCell") }

            cell.lblSelectAll.text = "collectionPoint.filter.selectAll".localized
            
            if !unselectedSwitchers.isEmpty  { // || size != nil
                cell.swSelectAll.setOn(false, animated: true)
            } else {
                cell.swSelectAll.setOn(true, animated: true)
            }

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as? FilterTableViewCell else { fatalError("Could not dequeue cell with identifier: FilterCell") }

            let type = types[indexPath.row]
            cell.lblTypeOtTrash.text = type.localizedName

            cell.swType.tag = indexPath.row
            
                if unselectedSwitchers.contains(cell.swType.tag) {
                    cell.swType.setOn(false, animated: false)
                } else {
                    cell.swType.setOn(true, animated: false)
                }

            return cell
        }
    }

    // MARK: - Table view Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    // MARK: - Picker view Data Source

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Junkyard.Category.allValues.count + 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

		if row > 0 {
			return Junkyard.Category.allValues[row - 1].localizedName
		}
		return "collectionPoint.size.all".localized
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        defaults.set(row, forKey: "Row")

		if row > 0 {
			self.size = Junkyard.Category.allValues[row - 1]
		} else {
			self.size = nil
		}
        defaults.set(self.size?.rawValue, forKey: "FilterSize")
		tfDisplay.text = self.size?.localizedName ?? "collectionPoint.size.all".localized
    }

//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        let titleData = sizes[row]
//        let myTitle = NSAttributedString(string: titleData, attributes: [NSForegroundColorAttributeName: Theme.current.color.green])
//        return myTitle
//    }

    @IBAction func switchSelectAllTouched(_ sender: UISwitch) {
        if sender.isOn {
            tableView.reloadData()
            for i in 0...types.count - 1 {
                filterTypes.append(types[i].rawValue)
                defaults.set(filterTypes, forKey: "FilterTypes")
            }
            unselectedSwitchers = []
            defaults.set(unselectedSwitchers, forKey: "UnselectedSwitchers")
        } else {
            tableView.reloadData()
            filterTypes = []
            defaults.set(filterTypes, forKey: "FilterTypes")
            for i in 0...types.count - 1 {
                unselectedSwitchers.append(i)
                defaults.set(unselectedSwitchers, forKey: "UnselectedSwitchers")
            }
        }
    }
    
    func sizeSelected(size:Junkyard.Category?) {
        filterTypes = []
        unselectedSwitchers = []
        if size == .dustbin {
            tableView.reloadData()
            for s in 0...types.count - 1 {
                let scrapyardType = types[s].rawValue
                var equals = false
                for d in 0...dustbinTypes.count - 1 {
                    let dustbinType = dustbinTypes[d].rawValue
                    if scrapyardType == dustbinType {
                        equals = true
                        break
                    }
                }
                if equals == true {
                    filterTypes.append(types[s].rawValue)
                } else {
                    unselectedSwitchers.append(s)
                }
            }
            defaults.set(filterTypes, forKey: "FilterTypes")
            defaults.set(unselectedSwitchers, forKey: "UnselectedSwitchers")
        } else {
            tableView.reloadData()
            for i in 0...types.count - 1 {
                filterTypes.append(types[i].rawValue)
            }
            defaults.set(filterTypes, forKey: "FilterTypes")
            defaults.set(unselectedSwitchers, forKey: "UnselectedSwitchers")
        }
    }

    @IBAction func typeSelected(_ sender: UISwitch) {
        if sender.isOn {
            sender.setOn(true, animated: true)
            filterTypes.append(types[sender.tag].rawValue)
            defaults.set(filterTypes, forKey: "FilterTypes")
            unselectedSwitchers = unselectedSwitchers.filter{ $0 != sender.tag }
            defaults.set(unselectedSwitchers, forKey: "UnselectedSwitchers")
            if unselectedSwitchers.count == 0 {
                tableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
        } else {
            sender.setOn(false, animated: true)
            filterTypes = filterTypes.filter{ $0 != types[sender.tag].rawValue }
            defaults.set(filterTypes, forKey: "FilterTypes")
            unselectedSwitchers.append(sender.tag)
            defaults.set(unselectedSwitchers, forKey: "UnselectedSwitchers")
            if unselectedSwitchers.count == 1 {
                tableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
        }
    }

}

class FilterTableViewCell: UITableViewCell {

    @IBOutlet var lblTypeOtTrash: UILabel!

    @IBOutlet var swType: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()

        lblTypeOtTrash.font = Theme.current.font.text
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        lblTypeOtTrash.text = ""
    }

}

class SelectAllTableViewCell: UITableViewCell {

    @IBOutlet var lblSelectAll: UILabel!

    @IBOutlet var swSelectAll: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()

        lblSelectAll.font = Theme.current.font.boldText
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        lblSelectAll.text = ""
    }

}
