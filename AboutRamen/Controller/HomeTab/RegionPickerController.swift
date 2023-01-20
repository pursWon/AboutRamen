import UIKit

class RegionPickerController: UIViewController {
    // MARK: - UI
    @IBOutlet var pickerView: UIView!
    @IBOutlet var cityPicker: UIPickerView!
    @IBOutlet var guPicker: UIPickerView!
    @IBOutlet var regionStackView: UIStackView!
    @IBOutlet var myReionLabel: UILabel!
    @IBOutlet var regionSelectButton: UIButton!
    // MARK: - Properties
    let regionData = RegionData()
    
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
    
    @IBAction func regionSelectButton(_ sender: UIButton) {
        
    }
}

// MARK: - Picker
extension RegionPickerController: UIPickerViewDelegate, UIPickerViewDataSource {
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
        }
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    
}


