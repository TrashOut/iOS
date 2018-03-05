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

protocol TrashFilterDelegate {

	func filterDidSet(filter: TrashFilter)

}



class DumpsFilterViewController: ViewController,
	UITableViewDataSource, UITableViewDelegate,
	UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
	UIPickerViewDelegate, UIPickerViewDataSource,
	UITextFieldDelegate {

    @IBOutlet var loadingView: UIView! {
        didSet {
            loadingView.isHidden = true
        }
    }

    //@IBOutlet var vDescSeparator: [UIView]!

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBOutlet var tfLastUpdate: UITextField!
	var pickerView: UIPickerView!


    @IBOutlet var lblStatusOfTrash: UILabel!
    @IBOutlet var lblDateOfLastUpdate: UILabel!
    @IBOutlet var lblSizeOfTrash: UILabel!
    @IBOutlet var lblTypeOfTrash: UILabel!
	@IBOutlet var lblAccessibility: UILabel!

	@IBOutlet var statusTableView: UITableView!
	@IBOutlet var sizeCollectionView: UICollectionView!
	@IBOutlet var typeCollectionView: UICollectionView!
	@IBOutlet var accessibilityTableView: UITableView!


	@IBOutlet var cnsTypeCollectionViewHeight: NSLayoutConstraint!

	var filter: TrashFilter = TrashFilter.cachedFilter

	var delegate: TrashFilterDelegate? = nil

    fileprivate var pickerData: [TrashFilter.LastUpdateFilter] = TrashFilter.LastUpdateFilter.allValues

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "trash.filter.header".localized

        let backButton = UIBarButtonItem.init(title: "global.cancel".localized, style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = backButton
        let filterButton = UIBarButtonItem(title: "global.filter".localized, style: .plain, target: self, action: #selector(filterTrash))
        navigationItem.rightBarButtonItem = filterButton


		self.setupLastUpdateSelect()
        self.setupTexts()
		self.setupDesign()
		self.updateHeightForTypes()
		self.showLastUpdate()
    }

	func setupLastUpdateSelect() {
		pickerView = UIPickerView()
		pickerView.dataSource = self
		pickerView.delegate = self
		tfLastUpdate.inputView = pickerView
		tfLastUpdate.delegate = self
		tfLastUpdate.font = Theme.current.font.text

		let doneButton = UIBarButtonItem.init(title: "global.done".localized, style: .done, target: self, action: #selector(didSelectLastUpdate))
		let toolbar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
		toolbar.items = [UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton]
		toolbar.barStyle = .default
		toolbar.sizeToFit()
		tfLastUpdate.inputAccessoryView = toolbar

	}

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if textField == tfLastUpdate { // enable editing using only pickerview
			return false
		}
		return true
	}

	func didSelectLastUpdate() {
		tfLastUpdate.resignFirstResponder()
	}

	func setupDesign() {
		lblStatusOfTrash.textColor = Theme.current.color.green
		lblDateOfLastUpdate.textColor = Theme.current.color.green
		lblSizeOfTrash.textColor = Theme.current.color.green
		lblTypeOfTrash.textColor = Theme.current.color.green
		lblAccessibility.textColor = Theme.current.color.green
		statusTableView.tableFooterView = UIView.init(frame: .zero)
		accessibilityTableView.tableFooterView = UIView.init(frame: .zero)
	}

	func setupTexts() {
		lblStatusOfTrash.text = "trash.status".localized
		lblDateOfLastUpdate.text = "trash.filter.dateOfLastUpdate".localized
		lblSizeOfTrash.text = "trash.trashSize".localized
		lblTypeOfTrash.text = "trash.trashType".localized
		lblAccessibility.text = "trash.accessibility".localized
	}

	func updateHeightForTypes() {
		cnsTypeCollectionViewHeight.constant = (140 * ceil(CGFloat(Trash.TrashType.allValues.count) / 3))
	}

	func showLastUpdate() {
		if let lu = filter.lastUpdate {
			if let index = pickerData.index(of: lu) {
				pickerView.selectRow(index, inComponent: 0, animated: false)
				tfLastUpdate.text = pickerData[index].localizedName
			}
		}
	}


    // MARK: - Actions

    func close() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

	func filterTrash() {
		filter.cache()
		delegate?.filterDidSet(filter: self.filter)
		navigationController?.dismiss(animated: true, completion: nil)
	}



    // MARK: - Picker view Data Source

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].localizedName
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		self.filter.lastUpdate = pickerData[row]
		tfLastUpdate.text = pickerData[row].localizedName
    }



	// MARK: - Table view data source


	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView == statusTableView {
			return Trash.DisplayStatus.allValues.count
		}
		if tableView == accessibilityTableView {
			return 4
		}
		return 0
	}


	func statusTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "StatusCell") as! FilterTrashStatusTableViewCell
		let status = Trash.DisplayStatus.allValues[indexPath.row]
		let state = self.filter.status[status] ?? true
		cell.lblName.text = status.localizedName
		cell.swSelection.isOn = state
		cell.switchAction = { [weak self] (state) in
			self?.filter.status[status] = state
		}
		return cell
	}

	func accessibilityTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "StatusCell") as! FilterTrashStatusTableViewCell
		let type = Accessibility.types[indexPath.row]
		let state = type.value(self.filter.accessibility)
		cell.lblName.text = type.localizedName
		cell.swSelection.isOn = state
		cell.switchAction = { [unowned self] (state) in
			type.set(value: state, accessibility: &self.filter.accessibility)
		}
		return cell
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if tableView == statusTableView {
			return statusTableView(tableView, cellForRowAt: indexPath)
		}
		if tableView == accessibilityTableView {
			return accessibilityTableView(tableView, cellForRowAt: indexPath)
		}
		return UITableViewCell()
	}

	// MARK: - Collection view delegate

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == sizeCollectionView {
			return Trash.Size.allValues.count
		}
		if collectionView == typeCollectionView {
			return Trash.TrashType.allValues.count
		}
		return 0
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

		if collectionView == sizeCollectionView {
			let size = collectionView.bounds.size
			return CGSize.init(width: (size.width - 20) / 3, height: size.height-10)
		}
		if collectionView == typeCollectionView {
			let size = collectionView.bounds.size
			let height: CGFloat = 140
			return CGSize.init(width: (size.width - 20) / 3, height: height)
		}
		return .zero
	}

	func sizeCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SizeCell", for: indexPath) as! FilterTrashSizeCollectionViewCell
		let size = Trash.Size.allValues[indexPath.item]
		cell.size = size
		if filter.sizes.contains(size) {
			cell.btnTrashSize.isSelected = true
		}
		cell.switchAction = { [weak self] (selected) in
			if selected {
				self?.addSize(size)
			} else {
				self?.removeSize(size)
			}
		}
		return cell
	}

	func removeSize(_ size: Trash.Size) {
		if let index = self.filter.sizes.index(of: size) {
			self.filter.sizes.remove(at: index)
		}
	}
	func addSize(_ size: Trash.Size) {
		if self.filter.sizes.contains(size) == false {
			self.filter.sizes.append(size)
		}
	}

	func typeCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TypeCell", for: indexPath) as! FilterTrashTypeCollectionViewCell
		let type = Trash.TrashType.allValues[indexPath.item]
		cell.trashType = type
		if filter.types.contains(type) {
			cell.btnTrashType.isSelected = true
		}
		cell.switchAction = { [weak self] (selected) in
			if selected {
				self?.addType(type)
			} else {
				self?.removeType(type)
			}
		}
		return cell
	}

	func removeType(_ type: Trash.TrashType) {
		if let index = self.filter.types.index(of: type) {
			self.filter.types.remove(at: index)
		}
	}

	func addType(_ type: Trash.TrashType) {
		if self.filter.types.contains(type) == false {
			self.filter.types.append(type)
		}
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == sizeCollectionView {
			return sizeCollectionView(collectionView, cellForItemAt: indexPath)
		}
		if collectionView == typeCollectionView {
			return typeCollectionView(collectionView, cellForItemAt: indexPath)
		}
		return UICollectionViewCell()
	}
}


class FilterTrashStatusTableViewCell: UITableViewCell {

	@IBOutlet var lblName: UILabel!
	@IBOutlet var swSelection: UISwitch!


	var switchAction: ((Bool) -> ())?

	override func awakeFromNib() {
		super.awakeFromNib()
		swSelection.addTarget(self, action: #selector(switched), for: .valueChanged)
	}

	func switched() {
		if let action = switchAction {
			action(swSelection.isOn)
		}
	}

}


class FilterTrashSizeCollectionViewCell: UICollectionViewCell {


	@IBOutlet var btnTrashSize: TrashTypeButton!
	@IBOutlet var lblTrashSizeName: UILabel!

	var switchAction: ((Bool) -> ())?

	var size: Trash.Size? {
		didSet {
			guard let size = size else { return }
			self.lblTrashSizeName.text = size.localizedName
			self.btnTrashSize.setImage(size.image, for: .normal)
			self.btnTrashSize.selectedColor = size.highlightColor
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		btnTrashSize.addTarget(self, action: #selector(switched), for: .touchUpInside)
	}

	func switched() {
		btnTrashSize.isSelected = !btnTrashSize.isSelected
		if let action = switchAction {
			action(btnTrashSize.isSelected)
		}
	}


}

class FilterTrashTypeCollectionViewCell: UICollectionViewCell {


	@IBOutlet var btnTrashType: TrashTypeButton!
	@IBOutlet var lblTrashTypeName: UILabel!

	var switchAction: ((Bool) -> ())?


	var trashType: Trash.TrashType? {
		didSet {
			guard let trashType = trashType else { return }
			self.lblTrashTypeName.text = trashType.localizedName
			self.btnTrashType.setImage(trashType.image, for: .normal)
			self.btnTrashType.selectedColor = trashType.highlightColor
			self.btnTrashType.setImage(trashType.highlightImage, for: .selected)
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		btnTrashType.addTarget(self, action: #selector(switched), for: .touchUpInside)
	}

	func switched() {
		btnTrashType.isSelected = !btnTrashType.isSelected
		if let action = switchAction {
			action(btnTrashType.isSelected)
		}
	}

}
