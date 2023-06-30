//
//  CoinTableViewCell.swift
//  CoinProject
//
//  Created by 0000 on 2023/6/28.
//

import UIKit
import Charts
class CoinTableViewCell: UITableViewCell, ChartViewDelegate {
    
    @IBOutlet weak var selectValuesLabel: UILabel!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinIconImageView: UIImageView!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var coinChineseLabel: UILabel!
    @IBOutlet weak var coinIncreaseLabel: UILabel!
    @IBOutlet weak var coinRateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectValuesLabel.text = ""
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
        dataSet.mode = .cubicBezier
        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.lineWidth = 1.3
        dataSet.colors = [UIColor.systemGreen]
        
        let data = LineChartData(dataSet: dataSet)
        lineChartView.data = data
    }
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        selectValuesLabel.text = "\(entry.y)"
    }
}
