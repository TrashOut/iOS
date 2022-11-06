//
//  TrashOut
//  Copyright 2017 TrashOut NGO. All rights reserved.
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
import Charts

class StatisticViewController: ViewController,
    UITableViewDelegate, UITableViewDataSource,
    CountryPickerDelegate {

    @IBOutlet var lblCountry: UILabel!
    @IBOutlet var tblStatistics: UITableView!
    @IBOutlet var lblStatsTitle: UILabel!
    @IBOutlet var pieChartView: PieChartView!

    var manager: StatisticsManager = StatisticsManager()

    var country: Area? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "statistics.header".localized

        lblStatsTitle.textColor = Theme.current.color.green
        lblStatsTitle.text = "home.statisticsInArea".localized
        lblCountry.text = "global.worldwide".localized

        self.prepareChart()
        self.setupChart()

		var dataAvailable = true
		for type in StatisticsManager.StatisticsType.allValues {
			if manager.worldwide[type] == nil {
				dataAvailable = false
			}
		}
		if !dataAvailable {
			self.loadData(isFirstLoad: true)
		}
    }

	func loadData(isFirstLoad: Bool = false) {
		LoadingView.show(on: self.view, style: isFirstLoad ? .white : .transparent)
        manager.loadStatistics(for: country, completion: { [weak self] in
            LoadingView.hide()
			NoDataView.hide(from: self?.tblStatistics)
            self?.setupChart()
            self?.tblStatistics.reloadData()
            if let area = self?.country {
                self?.lblCountry.text = area.country
            } else {
                self?.lblCountry.text = "global.worldwide".localized
            }
        }) { [weak self] error in
            LoadingView.hide()
			NoDataView.show(over: self?.tblStatistics, text: "No data available".localized)
			self?.show(error: error)
        }
    }
    

    // MARK: - Chart

    func prepareChart() {
        pieChartView.noDataText = "No data available".localized

        pieChartView.isUserInteractionEnabled = false
        pieChartView.legend.enabled = false
        pieChartView.chartDescription.enabled = false
    }

    func setupChart() {
        var entries: [ChartDataEntry] = []
        let types = StatisticsManager.StatisticsType.allValues
        for i in 0 ..< types.count {
            var value: Double!
            if let area = self.country {
                value = Double(manager.stats[area]?[types[i]] ?? 0)
            } else {
                value = Double(manager.worldwide[types[i]] ?? 0)
            }
            let entry = ChartDataEntry.init(x: Double(i), y: value)
            entries.append(entry)
        }

        let dataset = PieChartDataSet.init(entries: entries, label: "")
        dataset.colors = types.map { $0.color }

        let data = PieChartData.init(dataSets: [dataset])

        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        data.setValueFormatter(nf)

        pieChartView.rotationAngle = CGFloat(270) + CGFloat(360) / CGFloat(8) // in degrees, wtf?
        pieChartView.data = data
        pieChartView.animate(yAxisDuration: 1, easingOption: .easeInOutCubic)
    }

    // MARK: - Statistics table

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return StatisticsManager.StatisticsType.allValues.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticsTableViewCell") as! StatisticsTableViewCell

        let type = StatisticsManager.StatisticsType.allValues[indexPath.row]
        cell.ivIcon.image = type.image
        cell.lblTitle.text = type.localizedName
        cell.lblNumber.textColor = type.color
        var value: Int!
        if let area = self.country {
            value = manager.stats[area]?[type] ?? 0
        } else {
            value = manager.worldwide[type] ?? 0
        }

        cell.lblNumber.text = NumberFormatter.localizedString(from: NSNumber.init(value: value), number: .decimal)
        return cell
    }

    // MARK: - Action

    @IBAction func selectArea() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CountryPickerViewController") as! CountryPickerViewController
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func countryPicker(_: CountryPickerViewController, didSelect country: Area?) {
        self.country = country
        self.loadData()
    }

}

class StatisticsTableViewCell: UITableViewCell {

    @IBOutlet var ivIcon: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblNumber: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle.textColor = Theme.current.color.lightGray
        lblTitle.font = Theme.current.font.text
        lblNumber.font = Theme.current.font.text
    }

}

extension NumberFormatter: ValueFormatter {

    public func stringForValue(_ value: Double,
                               entry _: ChartDataEntry,
                               dataSetIndex _: Int,
                               viewPortHandler _: ViewPortHandler?) -> String {
        return self.string(from: NSNumber.init(value: value)) ?? "0"
    }

}
