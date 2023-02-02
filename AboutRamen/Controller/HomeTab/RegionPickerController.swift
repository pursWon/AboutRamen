import UIKit

class RegionPickerController: UIViewController {
    // MARK: - UI
    @IBOutlet var pickerView: UIView!
    @IBOutlet var cityPicker: UIPickerView!
    @IBOutlet var guPicker: UIPickerView!
    @IBOutlet var regionStackView: UIStackView!
    
    // MARK: - Properties
    let regionData = RegionData()
    /// 지역명 프로토콜 변수
    var delegateRegion: RegionDataProtocol?
    /// 경도, 위도 프로토콜 변수
    var delegateLocation: LocationDataProtocol?
    /// 도시 이름 데이터를 담을 변수
    var selectedCity: String = ""
    /// 구, 군이름 데이터를 담을 변수
    var selectedGu: String = ""
    /// 경도, 위도 데이터를 담을 변수
    var longlat: (Double, Double) = (0,0)
    
    let list = RegionData.list
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemOrange
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 100)]
        navigationController?.navigationBar.backItem?.backBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
        setUpBorder()
        delegateRegion?.sendRegionData(city: "서울시", gu: "강남구")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpBorder() {
        let views: [UIView] = [regionStackView]
        
        views.forEach { view in
            view.layer.borderWidth = 2
            view.layer.borderColor = UIColor.black.cgColor
        }
    }
}
// TODO: 수정된 RegionData 기반으로 picker 데이터 수정해보기 
extension RegionPickerController: UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == cityPicker {
            return list.count
        } else if cityPicker.selectedRow(inComponent: 0) == 0 {
            return list[0].guList.count
        } else if cityPicker.selectedRow(inComponent: 0) == 1 {
            return list[1].guList.count
        } else if cityPicker.selectedRow(inComponent: 0) == 2 {
            return list[2].guList.count
        } else if cityPicker.selectedRow(inComponent: 0) == 3 {
            return list[3].guList.count
        } else if cityPicker.selectedRow(inComponent: 0) == 4 {
            return list[4].guList.count
        } else if cityPicker.selectedRow(inComponent: 0) == 5 {
            return list[5].guList.count
        } else if cityPicker.selectedRow(inComponent: 0) == 6 {
            return list[6].guList.count
        } else if cityPicker.selectedRow(inComponent: 0) == 7 {
            return list[7].guList.count
        } else if cityPicker.selectedRow(inComponent: 0) == 8 {
            return list[8].guList.count
        } else if cityPicker.selectedRow(inComponent: 0) == 9 {
            return list[9].guList.count
        } else if cityPicker.selectedRow(inComponent: 0) == 10 {
            return list[10].guList.count
        } else if cityPicker.selectedRow(inComponent: 0) == 11 {
            return list[11].guList.count
        } else if cityPicker.selectedRow(inComponent: 0) == 12 {
            return list[12].guList.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == cityPicker {
            return list[row].city.rawValue
        } else if cityPicker.selectedRow(inComponent: 0) == 0 {
            return list[0].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 1 {
            return list[1].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 2 {
            return list[2].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 3 {
            return list[3].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 4 {
            return list[4].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 5 {
            return list[5].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 6 {
            return list[6].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 7 {
            return list[7].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 8 {
            return list[8].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 9 {
            return list[9].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 10 {
            return list[10].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 11 {
            return list[11].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 12 {
            return list[12].guList[row].gu
        }
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == cityPicker {
            guPicker.reloadAllComponents()
        } else if cityPicker.selectedRow(inComponent: 0) == 0 {
            selectedCity = list[0].city.rawValue
            selectedGu = list[0].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 1 {
            selectedCity = list[1].city.rawValue
            selectedGu = list[1].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 2 {
            selectedCity = list[2].city.rawValue
            selectedGu = list[2].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 3 {
            selectedCity = list[3].city.rawValue
            selectedGu = list[3].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 4 {
            selectedCity = list[4].city.rawValue
            selectedGu = list[4].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 5 {
            selectedCity = list[5].city.rawValue
            selectedGu = list[5].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 6 {
            selectedCity = list[6].city.rawValue
            selectedGu = list[6].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 7 {
            selectedCity = list[7].city.rawValue
            selectedGu = list[7].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 8 {
            selectedCity = list[8].city.rawValue
            selectedGu = list[8].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 9 {
            selectedCity = list[9].city.rawValue
            selectedGu = list[9].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 10 {
            selectedCity = list[10].city.rawValue
            selectedGu = list[10].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 11 {
            selectedCity = list[11].city.rawValue
            selectedGu = list[11].guList[row].gu
        } else if cityPicker.selectedRow(inComponent: 0) == 12 {
            selectedCity = list[12].city.rawValue
            selectedGu = list[12].guList[row].gu
        }
        
        delegateRegion?.sendRegionData(city: selectedCity, gu: selectedGu)
        
        for region in list {
            if selectedCity == region.city.rawValue {
                for index in 0..<region.guList.count {
                    if selectedGu == region.guList[index].gu {
                        longlat = region.guList[index].location
                    }
                }
            }
        }
        
        delegateLocation?.sendCurrentLocation(longlat: longlat)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
}
