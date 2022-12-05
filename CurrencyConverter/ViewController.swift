//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Selen Yanar on 4.12.2022.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var textField: UITextField!
    @IBOutlet var pickerView: UIPickerView!
    
    // MARK: - Properties
    var currencyCode: [String] = []
    var values: [Double] = []
    var activeCurrency = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        fetchJSON()
        textField.addTarget(self, action: #selector(updateView), for: .editingChanged)
    }
    
    @objc func updateView(input: Double) {
        guard let amountText = textField.text, let theAmountText = Double(amountText) else { return }
        if textField.text != "" {
            let total = theAmountText * activeCurrency
            priceLabel.text = String(format: "%.2f", total)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyCode.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyCode[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activeCurrency = values[row]
        updateView(input: activeCurrency)
    }
    
    //MARK: - Method
    
    func fetchJSON() {
        guard let url = URL(string:"https://v6.exchangerate-api.com/v6/893d51b829b825837c64c1b8/latest/TRY") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            // handle any errors if there are any
            if error != nil {
                print(error!)
                return
            }

            //safely unwrap the data
            guard let safeData = data else { return }

            // decode the JSON Data
            do {
                let results = try JSONDecoder().decode(ExchangeRates.self, from: safeData)
                self.currencyCode.append(contentsOf: results.conversion_rates.keys)
                self.values.append(contentsOf: results.conversion_rates.values)
                DispatchQueue.main.async {
                    self.pickerView.reloadAllComponents()
                }
            } catch {
              print(error)

            }
        }.resume()
    }
}

