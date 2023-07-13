//
//  ChartViewTableViewCell.swift
//  CoinProject
//
//  Created by 0000 on 2023/6/29.
//

import UIKit
import Charts

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var formattedString = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if formattedString.hasPrefix("#") {
            formattedString.remove(at: formattedString.startIndex)
        }
        
        if formattedString.count == 6 {
            var rgbValue: UInt64 = 0
            Scanner(string: formattedString).scanHexInt64(&rgbValue)
            
            let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
            
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        } else {
            self.init(red: 0, green: 0, blue: 0, alpha: alpha)
        }
    }
}


class XAxisValueFormatter: IndexAxisValueFormatter {
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



class ImageMarkerView: MarkerView {
    private var circleImageView: UIImageView?
    private var circleImage: UIImage?
    private var imageSize: CGSize
    
    init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets, image: UIImage?) {
        self.circleImage = image
        self.imageSize = image?.size ?? CGSize.zero
        
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.backgroundColor = .clear
        
        circleImageView = UIImageView(image: circleImage)
        circleImageView?.frame.size = imageSize
        addSubview(circleImageView!)
        
        circleImageView?.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        let offset = super.offsetForDrawing(atPoint: point)
        return offset
    }
}

enum SelectedType {
    case day
    case oneWeek
    case oneMonth
    case threeMonth
    case oneYear
    case all
}


class ChartViewTableViewCell: UITableViewCell, ChartViewDelegate {
    var selectedType: SelectedType = .oneMonth
    var data: LineChartData!
    var minXIndex: Double = 0
    var maxXIndex: Double = 0
    var dataSet: LineChartDataSet!
    var allArray: [Double] = []
    var dayArray: [Double] = []
    var oneWeekArray: [Double] = []
    var oneMonthArray: [Double] = []
    var threeMonthArray: [Double] = []
    var oneYearArray: [Double] = []
    var oneDayCandleTimeArray: [TimeInterval] = []
    var oneWeekCandleTimeArray: [TimeInterval] = []
    var oneMonthCandleTimeArray: [TimeInterval] = []
    var threeMonthCandleTimeArray: [TimeInterval] = []
    var oneYearCandleTimeArray: [TimeInterval] = []
    var allCandleTimeArray: [TimeInterval] = []
    var oneDayCandleLogCalcArray: [Double] = []
    var oneWeekCandleLogCalcArray: [Double] = []
    var oneMonthCandleLogCalcArray: [Double] = []
    var threeMonthCandleLogCalcArray: [Double] = []
    var oneYearCandleLogCalcArray: [Double] = []
    var allCandleLogCalcArray: [Double] = []
    var dataEntries: [ChartDataEntry] = []
    var isUpRate: Bool = true
    let greenColor = UIColor(hexString: AppColor.green.rawValue)
    
    let chartType = ["線性走勢圖", "對數走勢圖"]
    var selectedChartType: String = "線性走勢圖"
    @IBOutlet weak var historyAverageView: UIView!
    @IBOutlet weak var historyAverageLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var threeMonthButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var threeMonthView: UIView!
    @IBOutlet weak var yearView: UIView!
    @IBOutlet weak var allView: UIView!
    @IBOutlet weak var realTimeByPriceLabel: UILabel!
    @IBOutlet weak var realTimeSellPriceLabel: UILabel!
    @IBOutlet weak var historyTimeLabel: UILabel!
    @IBOutlet weak var pickChartTypeView: UIPickerView!
    @IBOutlet weak var showPickViewButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        historyAverageView.isHidden = true
        setButton(exceptButton: monthButton, exceptView: monthView)
        lineChartView.setViewPortOffsets(left: 0, top: 0, right: 0, bottom: 20)
        pickChartTypeView.delegate = self
        pickChartTypeView.dataSource = self
        let defaultSelectedRow = 0
        pickChartTypeView.selectRow(defaultSelectedRow, inComponent: 0, animated: false)
        pickChartTypeView.isHidden = true
    }
    
    func changeChartViewData(dataArray: [Double], timeArray: [Double], logArray: [Double]) {
        lineChartView.data = nil
        lineChartView.xAxis.valueFormatter = nil
        lineChartView.marker = nil
        lineChartView.notifyDataSetChanged()
        var selectedArray: [Double] = dataArray
        if selectedChartType == "線性走勢圖" {
            selectedArray = dataArray
        } else {
            selectedArray = logArray
        }
        if selectedArray.isEmpty == false {
            minXIndex = timeArray[selectedArray.firstIndex(of: selectedArray.min() ?? 0) ?? 0]
            maxXIndex = timeArray[selectedArray.firstIndex(of: selectedArray.max() ?? 0) ?? 0]
        }
        
        dataEntries = []
        dataSet = nil
        for i in 0..<selectedArray.count {
            let formattedValue = String(format: "%.2f", selectedArray[i])
            let dataEntry = ChartDataEntry(x: timeArray[i], y: Double(formattedValue) ?? 0)
            dataEntries.append(dataEntry)
        }
        
        dataSet = LineChartDataSet(entries: dataEntries)
        dataSet.mode = .linear
        dataSet.drawCirclesEnabled = false
        dataSet.valueFormatter = self
        dataSet.highlightLineWidth = 1.5
        if (selectedArray.first ?? 0) > (selectedArray.last ?? 0) {
            isUpRate = false
            dataSet.colors = [UIColor.red]
//            dataSet.valueColors = [UIColor.red]
            dataSet.highlightColor = .red
        } else {
            isUpRate = true
            dataSet.highlightColor = greenColor
            dataSet.colors = [greenColor]
//            dataSet.valueColors = [greenColor]
        }
        dataSet.valueColors = [UIColor.black]
        dataSet.highlightEnabled = true
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.lineWidth = 1.5
        dataSet.valueFont = .systemFont(ofSize: 12)
        data = LineChartData(dataSet: dataSet)
        lineChartView.data = data
        
        if let data = lineChartView.data {
            if let lineDataSet = data.dataSets.first as? LineChartDataSet {
                let endColor = UIColor.white
                let colorLocations: [CGFloat] = [0.0, 1.0]
                if (selectedArray.first ?? 0) > (selectedArray.last ?? 0) {
                    if let gradient = CGGradient(colorsSpace: nil, colors: [UIColor.red.cgColor, endColor.cgColor] as CFArray, locations: colorLocations) {
                        lineDataSet.fill = LinearGradientFill(gradient: gradient, angle: 270)
                        lineDataSet.drawFilledEnabled = true
                    }
                } else {
                    if let gradient = CGGradient(colorsSpace: nil, colors: [greenColor.cgColor, endColor.cgColor] as CFArray, locations: colorLocations) {
                        lineDataSet.fill = LinearGradientFill(gradient: gradient, angle: 270)
                        lineDataSet.drawFilledEnabled = true
                    }
                }
            }
        }
        
        if let selectedEntry = dataEntries.first {
            let originalValue = selectedArray[dataEntries.firstIndex(of: selectedEntry) ?? 0]
            let coinImage = UIImage(named: "black")
            let coinMarker = ImageMarkerView(color: .clear, font: .systemFont(ofSize: 10), textColor: .white, insets: .zero, image: coinImage)
            coinMarker.refreshContent(entry: selectedEntry, highlight: Highlight(x: selectedEntry.x, y: originalValue, dataSetIndex: 0))
            lineChartView.marker = coinMarker
        }
        
        lineChartView.notifyDataSetChanged()
    }
    
    @IBAction func didShowPickerViewTapped(_ sender: Any) {
        if showPickViewButton.isSelected {
            showPickViewButton.isSelected = false
            pickChartTypeView.isHidden = true
        } else {
            showPickViewButton.isSelected = true
            pickChartTypeView.isHidden = false
        }
    }
    
    @IBAction func didDayButtonTapped(_ sender: Any) {
        setButton(exceptButton: dayButton, exceptView: dayView)
        changeChartViewData(dataArray: dayArray, timeArray: oneDayCandleTimeArray, logArray: oneDayCandleLogCalcArray)
        selectedType = .day
    }
    
    @IBAction func didWeekButtonTapped(_ sender: Any) {
        setButton(exceptButton: weekButton, exceptView: weekView)
        changeChartViewData(dataArray: oneWeekArray, timeArray: oneWeekCandleTimeArray, logArray: oneWeekCandleLogCalcArray)
        selectedType = .oneWeek
    }
    @IBAction func didMonthButtonTapped(_ sender: Any) {
        setButton(exceptButton: monthButton, exceptView: monthView)
        changeChartViewData(dataArray: oneMonthArray, timeArray: oneMonthCandleTimeArray, logArray: oneMonthCandleLogCalcArray)
        selectedType = .oneMonth
    }
    @IBAction func didThreeMonthButtonTapped(_ sender: Any) {
        setButton(exceptButton: threeMonthButton, exceptView: threeMonthView)
        changeChartViewData(dataArray: threeMonthArray, timeArray: threeMonthCandleTimeArray, logArray: threeMonthCandleLogCalcArray)
        selectedType = .threeMonth
    }
    @IBAction func didYearButtonTapped(_ sender: Any) {
        setButton(exceptButton: yearButton, exceptView: yearView)
        changeChartViewData(dataArray: oneYearArray, timeArray: oneYearCandleTimeArray, logArray: oneYearCandleLogCalcArray)
        selectedType = .oneYear
    }
    @IBAction func didAllButtonTapped(_ sender: Any) {
        setButton(exceptButton: allButton, exceptView: allView)
        changeChartViewData(dataArray: allArray, timeArray: allCandleTimeArray, logArray: allCandleLogCalcArray)
        selectedType = .all
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setButton(exceptButton currentButton: UIButton, exceptView currentView: UIView) {
        let buttons: [UIButton] = [
            dayButton, weekButton, monthButton,
            threeMonthButton, yearButton, allButton
        ]
        
        let views: [UIView] = [
            dayView, weekView, monthView,
            threeMonthView, yearView, allView
        ]
        
        for button in buttons {
            if button != currentButton {
                button.titleLabel?.textColor = .gray
                button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            } else {
                button.titleLabel?.textColor = .black
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            }
        }
        
        for view in views {
            if view != currentView {
                view.isHidden = true
            } else {
                view.isHidden = false
            }
        }
    }
    
    func setChartView(dataArray: [Double]) {
        lineChartView.delegate = self
        lineChartView.chartDescription.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.xAxis.enabled = false
        lineChartView.leftAxis.enabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        
        changeChartViewData(dataArray: oneMonthArray, timeArray: oneMonthCandleTimeArray, logArray: oneMonthCandleLogCalcArray)
    }
    
    func chartViewDidEndPanning(_ chartView: ChartViewBase) {
        guard let lineChartView = chartView as? LineChartView else {
            return
        }
        historyAverageView.isHidden = true
        lineChartView.data?.dataSets.forEach { dataSet in
            if let lineChartDataSet = dataSet as? LineChartDataSet {
                lineChartView.highlightValues([])
            }
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let timestamp: TimeInterval = entry.x
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 8 * 60 * 60)
        let date = Date(timeIntervalSince1970: timestamp)
        let dateString = dateFormatter.string(from: date)
        historyTimeLabel.text = dateString
        
        let index = chartView.data?.dataSets[0].entryIndex(entry: entry) ?? 0
        
        switch selectedType{
        case.day:
            historyAverageLabel.text = dayArray[index].formattedWithSeparator()
        case.oneWeek:
            historyAverageLabel.text = oneWeekArray[index].formattedWithSeparator()
        case.oneMonth:
            historyAverageLabel.text = oneMonthArray[index].formattedWithSeparator()
        case.threeMonth:
            historyAverageLabel.text = threeMonthArray[index].formattedWithSeparator()
        case.oneYear:
            historyAverageLabel.text = oneYearArray[index].formattedWithSeparator()
        case.all:
            historyAverageLabel.text = allArray[index].formattedWithSeparator()
        }
        
        historyAverageView.isHidden = false
    }
}

extension ChartViewTableViewCell: ValueFormatter {
    func stringForValue(_ value: Double, entry: Charts.ChartDataEntry, dataSetIndex: Int, viewPortHandler: Charts.ViewPortHandler?) -> String {
        if entry.x == minXIndex || entry.x == maxXIndex {
            entry.icon = UIImage(named: "fullBlack")
            let index = lineChartView.data?.dataSets[0].entryIndex(entry: entry) ?? 0
            switch selectedType{
            case.day:
                return dayArray[index].formattedWithSeparator()
            case.oneWeek:
                return oneWeekArray[index].formattedWithSeparator()
            case.oneMonth:
                return oneMonthArray[index].formattedWithSeparator()
            case.threeMonth:
                return threeMonthArray[index].formattedWithSeparator()
            case.oneYear:
                return oneYearArray[index].formattedWithSeparator()
            case.all:
                return allArray[index].formattedWithSeparator()
                
            }
        } else {
            return ""
        }
    }
    
}

extension ChartViewTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return chartType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return chartType[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedChartType = chartType[row]
        self.pickChartTypeView.isHidden = true
        self.showPickViewButton.setTitle(chartType[row] + " ▼", for: .normal)
        switch selectedType{
        case.day:
            changeChartViewData(dataArray: dayArray, timeArray: oneDayCandleTimeArray, logArray: oneDayCandleLogCalcArray)
        case.oneWeek:
            changeChartViewData(dataArray: oneWeekArray, timeArray: oneWeekCandleTimeArray, logArray: oneWeekCandleLogCalcArray)
        case.oneMonth:
            changeChartViewData(dataArray: oneMonthArray, timeArray: oneMonthCandleTimeArray, logArray: oneMonthCandleLogCalcArray)
        case.threeMonth:
            changeChartViewData(dataArray: threeMonthArray, timeArray: threeMonthCandleTimeArray, logArray: threeMonthCandleLogCalcArray)
        case.oneYear:
            changeChartViewData(dataArray: oneYearArray, timeArray: oneYearCandleTimeArray, logArray: oneYearCandleLogCalcArray)
        case.all:
            changeChartViewData(dataArray: allArray, timeArray: allCandleTimeArray, logArray: allCandleLogCalcArray)
        }
    }
}
