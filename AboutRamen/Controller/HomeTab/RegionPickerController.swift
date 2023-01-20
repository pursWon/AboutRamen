import UIKit

class RegionPickerController: UIViewController {
    // MARK: - UI
    @IBOutlet var cityPicker: UIPickerView!
    @IBOutlet var guPicker: UIPickerView!
    @IBOutlet var regionStackView: UIStackView!
    
    // MARK: - Properties
    let regionData = RegionData()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemOrange
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

