import UIKit

/// 지역 선택 화면
class RegionPickerController: UIViewController {
    // MARK: - UI
    @IBOutlet var pickerView: UIView!
    @IBOutlet var regionPickerView: UIPickerView!
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var chooseLabel: UILabel!
    @IBOutlet var saveButton: UIBarButtonItem!
    
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
    /// 현재 지역 위치를 알려줄 변수
    var address: (city: String?, gu: String?)
    /// 경도, 위도 데이터를 담을 변수
    var longlat: (long: Double?, lat: Double?)
    var firstPickerRow: Int = 0
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitData()
        setupBorder()
        setupNavigationbar()
    }
    
    // MARK: - Set up
    func setInitData() {
        view.backgroundColor = CustomColor.beige
        pickerView.backgroundColor = CustomColor.beige
        regionPickerView.backgroundColor = CustomColor.sage
        chooseLabel.textColor = CustomColor.deepGreen
        chooseLabel.font = UIFont.boldSystemFont(ofSize: 22)
        delegateRegion?.sendRegionData(city: "서울시", gu: "강남구")
    }
    
    func setupNavigationbar() {
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        saveButton.setTitleTextAttributes(attributes, for: .normal)
        navigationController?.navigationBar.backItem?.backBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
        
        let backButton = UIBarButtonItem(title: "홈", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        self.navigationItem.backBarButtonItem?.tintColor = .black
        backButton.setTitleTextAttributes(attributes, for: .normal)
    }
    
    func setupBorder() {
        regionPickerView.layer.borderWidth = 2
        regionPickerView.layer.borderColor = UIColor.black.cgColor
    }
    
    // MARK: - Action
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        if let city = address.city, let gu = address.gu {
            delegateRegion?.sendRegionData(city: city, gu: gu)
            
            if let long = longlat.long, let lat = longlat.lat {
                delegateLocation?.sendCurrentLocation(location: (long: long, lat: lat))
                navigationController?.popViewController(animated: true)
            }
        } else {
            showAlert(title: "두 지역을 모두 지정해주세요.", alertStyle: .oneButton)
        }
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension RegionPickerController: UIPickerViewDelegate, UIPickerViewDataSource {
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
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
}
