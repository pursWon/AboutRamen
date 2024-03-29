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
    var regionData: RegionInformation?
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
        
        if let region = region {
            guard let regionInformation = try? JSONDecoder().decode(RegionInformation.self, from: region) else { return }
            
            regionData = regionInformation
        }
        
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
        chooseLabel.font = UIFont(name: "BlackHanSans-Regular", size: 22)
        resultLabel.font = UIFont(name: "BlackHanSans-Regular", size: 24)
        delegateRegion?.sendRegionData(city: "서울시", gu: "강남구")
    }
    
    func setupNavigationbar() {
        let attributes = [NSAttributedString.Key.font: UIFont(name: "Recipekorea", size: 16)]
        saveButton.setTitleTextAttributes(attributes, for: .normal)
        navigationController?.navigationBar.backItem?.backBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
    }
    
    func setupBorder() {
        regionPickerView.clipsToBounds = true
        regionPickerView.layer.cornerRadius = 10
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
        guard let regionData = regionData else { return 0 }
        
        switch component {
        case 0:
            return regionData.region.count
        case 1:
            return regionData.region[firstPickerRow].local.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let regionData = regionData else { return "" }
        
        if pickerView == regionPickerView {
            
            switch component {
            case 0:
                return regionData.region[row].city
            case 1:
                return regionData.region[firstPickerRow].local[row].gu
            default:
                return nil
            }
        }
        
        return "-"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let regionData = regionData else { return }
        
        switch component {
        case 0:
            firstPickerRow = row
            let selectedItem = regionData.region[firstPickerRow]
            let city = selectedItem.city
            address = (city, nil)
            regionPickerView.reloadAllComponents()
            
        case 1:
            let selectedItem = regionData.region[firstPickerRow]
            address.gu = selectedItem.local[row].gu
            
        default:
            return
        }
        
        for region in regionData.region {
            if address.city == region.city {
                for index in 0..<region.local.count {
                    if address.gu == region.local[index].gu {
                        longlat = (region.local[index].longtitude, region.local[index].latitude)
                    }
                }
            }
        }
        
        resultLabel.text = "\(address.city ?? "-") \(address.gu ?? "-")"
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        guard let regionData = regionData else { return UIView() }
        
        var title = UILabel()
        title.font = UIFont(name: "Recipekorea", size: 20)
        title.textAlignment = .center
        
        switch component {
        case 0:
            title.text = regionData.region[row].city
        case 1:
            title.text = regionData.region[firstPickerRow].local[row].gu
        default:
            return UIView()
        }
        
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
}
