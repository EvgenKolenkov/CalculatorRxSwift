//
//  ViewController.swift
//  CalculatorNew
//
//  Created by Evgeniy Kolenkov on 7/20/18.
//  Copyright © 2018 Evgeniy Kolenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DisplayViewController: UIViewController {
    
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var commaButton: UIButton!
    
    let numberSubject = BehaviorSubject<String>(value: "0")
    let firstNumber = PublishSubject<String>()
    let secondNumber = PublishSubject<String>()
    var number = ""
    var operation = ""
    var perсentNumber = ""
    var result = 0.0
    var operationWasTapped = false
    var equalsWasTapped = false
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberSubject.subscribe(onNext: { value in
            self.displayLabel.text = value
            print("number = \(self.number)")
        })
            .disposed(by: bag)
        
        Observable.combineLatest(
            firstNumber.asObservable().map {Double($0)},
            secondNumber.asObservable().map {Double($0)},
            resultSelector: { first, second  in
                guard let firstNumber = first, let secondNumber = second else {return}
                self.checkOperation(firstNumber: firstNumber, secondNumber: secondNumber, operation: self.operation)
        })
            .subscribe()
            .disposed(by: bag)
    }
    
    
    @IBAction func digitButton(_ sender: UIButton) {
        guard let digit = sender.currentTitle else {return}
        if number == "0" && digit == "0" {return}
        if equalsWasTapped {
            number = ""
            firstNumber.onNext(checkNumber(digit: digit))
            operationWasTapped = false
            secondNumber.onNext("0")
            equalsWasTapped = false
            return
        }
        if operationWasTapped == false {
            firstNumber.onNext(checkNumber(digit: digit))
        } else {
            secondNumber.onNext(checkNumber(digit: digit))
        }
    }
    
    @IBAction func operationsButton(_ sender: UIButton) {
        guard let operation = sender.currentTitle else {return}
        self.operation = operation
        
        if operationWasTapped == true {
            handleResult(result: result)
            firstNumber.onNext(result != 0 ? String(result) : "0")
            secondNumber.onNext(operation == "x" || operation == "÷" ? "1" : "0")
            perсentNumber = String(result)
        } else {
            perсentNumber = number
        }
        operationWasTapped = true
        number = ""
        equalsWasTapped = false
    }
    
    @IBAction func commaButtonAction(_ sender: UIButton) {
            if number.contains(".") {return}
            if number != "" {
                number = number + "."
                numberSubject.onNext(number)
            }
       }
  
    @IBAction func perсentButtonAction(_ sender: UIButton) {
        if !operationWasTapped {
            number = String(convertNumber(number: number) / 100)
            handleResult(result: convertNumber(number: number))
            firstNumber.onNext(number)
        } else {
            number = String(convertNumber(number: perсentNumber) / 100 * convertNumber(number: number))
            handleResult(result: convertNumber(number: number))
            secondNumber.onNext(number)
        }
    }
    
    @IBAction func plusMinusButtonAction(_ sender: UIButton) {
        if !equalsWasTapped {
            operationWasTapped ? convertSubject(subject: secondNumber) :                 convertSubject(subject: firstNumber)
        } else {
            handleResult(result: -result)
            result = -result
        }
    }
    
    @IBAction func equalsButton(_ sender: UIButton) {
        equalsWasTapped = true
        handleResult(result: result)
        }
    
    @IBAction func clearButton(_ sender: UIButton) {
        firstNumber.onNext("0")
        secondNumber.onNext("0")
        operationWasTapped = false
        equalsWasTapped = false
        number = ""
        numberSubject.onNext("0")
        result = 0.0
    }
    
    func checkNumber(digit: String) -> String {
        number = number == "" ? digit : number + digit
        numberSubject.onNext(number)
        return number
    }
    
    func checkOperation(firstNumber: Double, secondNumber: Double, operation: String) {
        var result = 0.0
        switch operation {
        case "+": result = firstNumber + secondNumber
        case "-": result = firstNumber - secondNumber
        case "x": result = firstNumber * secondNumber
        case "÷": result = firstNumber / secondNumber
        default: break
        }
        self.result = result
        print("result\(self.result)")
    }
    
    func handleResult(result: Double) -> () {
        let convertResult = String(result)
        let convertIntResult = String(Int(result))
        if result.remainder(dividingBy: 1) == 0 {
           return numberSubject.onNext(convertIntResult)
        } else {
           return numberSubject.onNext(convertResult)
        }
    }
    
    func convertNumber(number: String) -> Double {
        guard let convertNumber = Double(number) else {return 0.0}
        return convertNumber
    }
    
    func convertSubject(subject: PublishSubject<String>) {
        let convertedNumber = convertNumber(number: number)
        if convertedNumber.remainder(dividingBy: 1) == 0 {
            number = String(Int(-convertedNumber))
            handleResult(result: -convertedNumber)
            subject.onNext(number)
        } else {
            number = String(-convertedNumber)
            handleResult(result: -convertedNumber)
            subject.onNext(number)
        }
    }
}
    

    

    



