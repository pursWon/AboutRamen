import UIKit

protocol SampleProtocol {
    func sendData(data: String)
}

class RegionPickerController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - UI
    @IBOutlet var pickerView: UIView!
    @IBOutlet var cityPicker: UIPickerView!
    @IBOutlet var guPicker: UIPickerView!
    @IBOutlet var regionStackView: UIStackView!
    @IBOutlet var myReionLabel: UILabel!
    @IBOutlet var regionSelectButton: UIButton!
    // MARK: - Properties
    let regionData = RegionData()
    var selectedCity: String = ""
    var selectedGu: String = ""
    var delegate: SampleProtocol?
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemOrange
        setUpBorder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpBorder() {
        let views: [UIView] = [regionStackView, myReionLabel]
        views.forEach { view in
            view.layer.borderWidth = 2
            view.layer.borderColor = UIColor.black.cgColor
        }
        
        myReionLabel.layer.cornerRadius = 10
    }

// MARK: - Picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == cityPicker {
            return regionData.cities.count
        } else if cityPicker.selectedRow(inComponent: 0) == 0 {
            return regionData.seoul.count
        } else if cityPicker.selectedRow(inComponent: 0) == 1 {
            return regionData.gangwon.count
        } else if cityPicker.selectedRow(inComponent: 0) == 2 {
            return regionData.gyeonggi.count
        } else if cityPicker.selectedRow(inComponent: 0) == 3 {
            return regionData.gyeongsang.count
        } else if cityPicker.selectedRow(inComponent: 0) == 4 {
            return regionData.gwangju.count
        } else if cityPicker.selectedRow(inComponent: 0) == 5 {
            return regionData.daegu.count
        } else if cityPicker.selectedRow(inComponent: 0) == 6 {
            return regionData.daejeon.count
        } else if cityPicker.selectedRow(inComponent: 0) == 7 {
            return regionData.busan.count
        } else if cityPicker.selectedRow(inComponent: 0) == 8 {
            return regionData.ulsan.count
        } else if cityPicker.selectedRow(inComponent: 0) == 9 {
            return regionData.incheon.count
        } else if cityPicker.selectedRow(inComponent: 0) == 10 {
            return regionData.jeolla.count
        } else if cityPicker.selectedRow(inComponent: 0) == 11 {
            return regionData.chungcheong.count
        } else if cityPicker.selectedRow(inComponent: 0) == 12 {
            return regionData.jeju.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == cityPicker {
            return regionData.cities[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 0 {
            return regionData.seoul[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 1 {
            return regionData.gangwon[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 2 {
            return regionData.gyeonggi[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 3 {
            return regionData.gyeongsang[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 4 {
            return regionData.gwangju[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 5 {
            return regionData.daegu[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 6 {
            return regionData.daejeon[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 7 {
            return regionData.busan[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 8 {
            return regionData.ulsan[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 9 {
            return regionData.incheon[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 10 {
            return regionData.jeolla[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 11 {
            return regionData.chungcheong[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 12 {
            return regionData.jeju[row]
        }
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == cityPicker {
            guPicker.reloadAllComponents()
        } else if cityPicker.selectedRow(inComponent: 0) == 0 {
            selectedCity = regionData.cities[0]
            selectedGu = regionData.seoul[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 1 {
            selectedCity = regionData.cities[1]
            selectedGu = regionData.gangwon[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 2 {
            selectedCity = regionData.cities[2]
            selectedGu = regionData.gyeonggi[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 3 {
            selectedCity = regionData.cities[3]
            selectedGu = regionData.gyeongsang[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 4 {
            selectedCity = regionData.cities[4]
            selectedGu = regionData.gwangju[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 5 {
            selectedCity = regionData.cities[5]
            selectedGu = regionData.daegu[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 6 {
            selectedCity = regionData.cities[6]
            selectedGu = regionData.daejeon[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 7 {
            selectedCity = regionData.cities[7]
            selectedGu = regionData.busan[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 8 {
            selectedCity = regionData.cities[8]
            selectedGu = regionData.ulsan[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 9 {
            selectedCity = regionData.cities[9]
            selectedGu = regionData.incheon[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 10 {
            selectedCity = regionData.cities[10]
            selectedGu = regionData.jeolla[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 11 {
            selectedCity = regionData.cities[11]
            selectedGu = regionData.chungcheong[row]
        } else if cityPicker.selectedRow(inComponent: 0) == 12 {
            selectedCity = regionData.cities[12]
            selectedGu = regionData.jeju[row]
        }
        
        delegate?.sendData(data: "\(selectedCity) \(selectedGu)")
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    @IBAction func selectButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
   
    
}

