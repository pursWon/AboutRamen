import UIKit

class RegionPickerController: UIViewController {
    
    @IBOutlet var cityPicker: UIPickerView!
    
    let cityNames: [String] = []
    let guNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        
    }
}

extension RegionPickerController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return
    }
    
    
}
