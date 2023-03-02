import UIKit

class RegionPickerController: UIViewController {
    // MARK: - UI
    @IBOutlet var pickerView: UIView!
    @IBOutlet var regionPickerView: UIPickerView!
    @IBOutlet var regionStackView: UIStackView!
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var chooseLabel: UILabel!
    
    // MARK: - Properties
    let regionData = RegionData()
    let list = RegionData.list
    /// 지역명 프로토콜 변수
    var delegateRegion: RegionDataProtocol?
    /// 경도, 위도 프로토콜 변수
    var delegateLocation: LocationDataProtocol?
    /// 도시 이름 데이터를 담을 변수
    var selectedCity: String = ""
    /// 구, 군이름 데이터를 담을 변수
    var selectedGu: String = ""
    var firstPickerRow: Int = 0
    /// 현재 지역 위치를 알려줄 변수
    var address: (city: String?, gu: String?)
    /// 경도, 위도 데이터를 담을 변수
    var longlat: (long: Double?, lat: Double?)
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = .systemOrange
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 100)]
        navigationController?.navigationBar.backItem?.backBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
        chooseLabel.font = UIFont.boldSystemFont(ofSize: 22)
        setUpBorder()
        delegateRegion?.sendRegionData(city: "서울시", gu: "강남구")
    }
    
    func setUpBorder() {
        regionStackView.layer.borderWidth = 2
        regionStackView.layer.borderColor = UIColor.black.cgColor
    }
}

// TODO: 수정된 RegionData 기반으로 picker 데이터 수정해보기 
extension RegionPickerController: UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return list.count
        case 1:
            return list[firstPickerRow].guList.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == regionPickerView {
            switch component {
            case 0:
                return list[row].city.rawValue
            case 1:
                return list[firstPickerRow].guList[row].gu
            default:
                return nil
            }
        }
        
        return "-"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            firstPickerRow = row
            let selectedItem = list[firstPickerRow]
            let city = selectedItem.city.rawValue
            address = (city, nil)
            regionPickerView.reloadAllComponents()
        case 1:
            let selectedItem = list[firstPickerRow]
            address.gu = selectedItem.guList[row].gu
        default:
            return
        }
        
        for region in list {
            if address.city == region.city.rawValue {
                for index in 0..<region.guList.count {
                    if address.gu == region.guList[index].gu {
                        longlat = region.guList[index].location
                    }
                }
            }
        }
        
        resultLabel.text = "\(address.city ?? "-") \(address.gu ?? "-")"
        
        delegateRegion?.sendRegionData(city: address.city ?? "-", gu: address.gu ?? "-")
        
        if let long = longlat.long, let lat = longlat.lat {
        delegateLocation?.sendCurrentLocation(longlat: (long, lat))
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
}
