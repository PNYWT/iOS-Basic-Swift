//
//  Combine.swift

import Foundation
import Combine

/*
 PassthroughSubject: ไม่เก็บค่าใด ๆ ส่งเฉพาะค่าที่เข้ามาใหม่ให้กับผู้สมัครเท่านั้น
 CurrentValueSubject: เก็บค่าล่าสุดและส่งให้กับผู้สมัครใหม่
 */

class HowToUseCombine: NSObject{
    
    func exPassthroughSubject() {
        let passthroughSubject = PassthroughSubject<String, Never>()
        
        let subscriber1 = passthroughSubject.sink { value in
            print("Subscriber 1 received: \(value)")
        }
        
        passthroughSubject.send("Hello")
        
        let subscriber2 = passthroughSubject.sink { value in
            print("Subscriber 2 received: \(value)")
        }
        
        passthroughSubject.send("World")
        
        // Output:
        // Subscriber 1 received: Hello
        // Subscriber 1 received: World
        // Subscriber 2 received: World
        /*
         อธิบาย: subscriber2 ไม่ได้รับค่า "Hello" เพราะมันถูกส่งก่อนที่ subscriber2 จะสมัครเข้ามา
         */
    }
    
    func exCurrentValueSubject() {
        let currentValueSubject = CurrentValueSubject<String, Never>("Initial Value")
        
        let subscriber1 = currentValueSubject.sink { value in
            print("Subscriber 1 received: \(value)")
        }
        
        currentValueSubject.send("Hello")
        
        let subscriber2 = currentValueSubject.sink { value in
            print("Subscriber 2 received: \(value)")
        }
        
        currentValueSubject.send("World")
        
        // Output:
        // Subscriber 1 received: Initial Value
        // Subscriber 1 received: Hello
        // Subscriber 2 received: Hello
        // Subscriber 1 received: World
        // Subscriber 2 received: World
        /*
         อธิบาย: subscriber2 ได้รับค่า "Hello" ที่เป็นค่าปัจจุบัน ณ เวลาที่สมัครเข้ามา และค่าปัจจุบันจะถูกส่งให้ทุกครั้งที่มีการเปลี่ยนแปลง
         */
    }
}

enum ViewModelError: Error {
    case dataLoadingFailed
}

struct IncomeExpenseList {
    var description: String
    var amount: Double
    var date: Date
}

class HowTouseCombineWithError: NSObject {
    
    private var itemsViewSubject = PassthroughSubject<[IncomeExpenseList], ViewModelError>()
    private var isLoadingSubject = PassthroughSubject<Bool, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var groupedData: [(date: Date, items: [IncomeExpenseList])] = []
    
    override init() {
        super.init()
        groupedData = []
    }
    
    init(tableView: HomeTableDetail) {
        super.init()
        setupBindings(tableView: tableView)
    }
    
    private func setupBindings(tableView: HomeTableDetail) {
        
        itemsViewSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Handle the error here
                    print("Error occurred: \(error)")
                }
            }, receiveValue: { [weak self] data in
                guard let self = self else { return }
                self.groupedData = self.groupItemsByDate(items: data)
                tableView.reloadData()
            })
            .store(in: &cancellables)
        
        isLoadingSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { loading in
                if loading {
                    // Show loading indicator
                    ProgressHUD.animate("Please wait...", .ballVerticalBounce)
                } else {
                    // Hide loading indicator
                    ProgressHUD.dismiss()
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }
            })
            .store(in: &cancellables)
        
        fetchViewData()
    }
    
    private func fetchViewData() {
        isLoadingSubject.send(true)
        
        // Simulate data loading with potential error
        let success = Bool.random()
        if success {
            let dataPage: [IncomeExpenseList] = [
                // ... (same as before)
            ]
            self.itemsViewSubject.send(dataPage)
            self.isLoadingSubject.send(false)
        } else {
            self.itemsViewSubject.send(completion: .failure(.dataLoadingFailed))
            self.isLoadingSubject.send(false)
        }
    }
    
    private func groupItemsByDate(items: [IncomeExpenseList]) -> [(date: Date, items: [IncomeExpenseList])] {
        let groupedDict = Dictionary(grouping: items) { (item: IncomeExpenseList) -> Date in
            return Calendar.current.startOfDay(for: item.date)
        }
        
        let sortedGroupedData = groupedDict.sorted { $0.key > $1.key }
        
        return sortedGroupedData.map { (key: Date, value: [IncomeExpenseList]) in
            return (date: key, items: value)
        }
    }
}
