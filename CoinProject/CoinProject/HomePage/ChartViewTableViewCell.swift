//
//  ChartViewTableViewCell.swift
//  CoinProject
//
//  Created by 0000 on 2023/6/29.
//

import UIKit
import Charts

class YourXAxisValueFormatter: IndexAxisValueFormatter {
  var labels: [String] = []

  init(monthlyTotalAmounts: [String: Int]) {
    let sortedItems = monthlyTotalAmounts.sorted { $0.key < $1.key }
    labels = sortedItems.map { $0.key }
 
    super.init()
  }

  override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    guard let index = labels.indices.last(where: { value >= Double($0) }) else {
      return ""
    }
    return labels[index]
  }
}


class ChartViewTableViewCell: UITableViewCell, ChartViewDelegate {

    @IBOutlet weak var lineChartView: LineChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setChartView()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setChartView() {
        lineChartView.delegate = self
        lineChartView.chartDescription.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.xAxis.enabled = false
        lineChartView.leftAxis.enabled = false
        lineChartView.rightAxis.enabled = false
        
        // 設定折線圖的數據
        var values:[Double] = []
        var valueArray: [Double] = []
        for _ in 1...30 {
            let randomValue = Double.random(in: 10...25)
            valueArray.append(randomValue)
        }
        var dataEntries: [ChartDataEntry] = []
        if valueArray.count >= 20 {
            while values.count < 20 {
                let randomIndex = Int.random(in: 0..<valueArray.count)
                let randomValue = valueArray[randomIndex]
                values.append(randomValue)
            }
        }
        
        for i in 0..<values.count {
                    let formattedValue = String(format: "%.2f", values[i])
                    let dataEntry = ChartDataEntry(x: Double(i), y: Double(formattedValue) ?? 0)
                    dataEntries.append(dataEntry)
        }
        
        let dataSet = LineChartDataSet(entries: dataEntries)
        dataSet.mode = .linear
        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.lineWidth = 2
        dataSet.colors = [UIColor.red]
        
        let data = LineChartData(dataSet: dataSet)
        lineChartView.data = data
        
//        if let maxEntry = dataEntries.max(by: { $0.y < $1.y }),
//                    let minEntry = dataEntries.min(by: { $0.y < $1.y }) {
//                    lineChartView.marker = ChartMarker(color: UIColor.clear, font: UIFont.systemFont(ofSize: 10), textColor: UIColor.white, insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
//                    lineChartView.marker?.refreshContent(entry: maxEntry, highlight: Highlight(x: maxEntry.x, y: maxEntry.y, dataSetIndex: 0))
//                    lineChartView.marker?.refreshContent(entry: minEntry, highlight: Highlight(x: minEntry.x, y: minEntry.y, dataSetIndex: 0))
//                }
        
        if let data = lineChartView.data {
            if let lineDataSet = data.dataSets.first as? LineChartDataSet {
                let startColor = UIColor.red
                let endColor = UIColor.white
                let gradientColors = [startColor.cgColor, endColor.cgColor] as CFArray
                let colorLocations: [CGFloat] = [0.0, 1.0]
                if let gradient = CGGradient(colorsSpace: nil, colors: gradientColors, locations: colorLocations) {
                    lineDataSet.fill = LinearGradientFill(gradient: gradient, angle: 270)
                    lineDataSet.drawFilledEnabled = true
                }
            }
        }
    }
    
//    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
//        selectValuesLabel.text = "\(entry.y)"
//    }

}
