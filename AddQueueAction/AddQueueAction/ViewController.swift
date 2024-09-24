//
//  ViewController.swift
//  AddQueueAction
//
//  Created by Dev on 24/9/2567 BE.
//

import UIKit
import SnapKit

struct ViewMapping {
    var view: UIView
    var label: UILabel
    var id: Int?
    var timer: Timer?
}

class ViewController: UIViewController {
    
    private lazy var buttonAdd: UIButton = {
        let btn = UIButton()
        btn.setTitle("Add Queue", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        btn.addTarget(self, action: #selector(addQueue), for: .touchUpInside)
        return btn
    }()

    private func createBtn() {
        view.addSubview(buttonAdd)
        buttonAdd.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(100)
        }
    }

    @objc private func addQueue() {
        displayInQueue(id: Int.random(in: 0..<5))
    }
    
    // สร้าง UIView ทั้ง 3 ตัว
    let view1 = UIView()
    let view2 = UIView()
    let view3 = UIView()
    
    // สร้าง UILabel สำหรับแสดงจำนวนครั้งที่ id ถูกเรียกใช้
    let label1 = UILabel()
    let label2 = UILabel()
    let label3 = UILabel()
    
    // เก็บข้อมูลของ view แต่ละตัวด้วยการใช้ Struct
    var viewMapping: [ViewMapping] = []
    
    // สร้าง Queue สำหรับจัดการการแสดงผล
    let displayQueue = DispatchQueue(label: "display.queue", qos: .userInteractive)
    
    // Dictionary สำหรับเก็บจำนวนครั้งที่ id ถูกเรียกใช้
    var idCount: [Int: Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // เพิ่ม UIView ทั้ง 3 ตัวลงใน viewMapping และแสดงในหน้าจอ พร้อมกับ UILabel
        viewMapping = [
            ViewMapping(view: view1, label: label1, id: nil, timer: nil),
            ViewMapping(view: view2, label: label2, id: nil, timer: nil),
            ViewMapping(view: view3, label: label3, id: nil, timer: nil)
        ]
        
        setupViews()
        createBtn()
    }
    
    // ตั้งค่าเริ่มต้นให้ UIView ทั้ง 3 ตัว
    func setupViews() {
        let views = [view1, view2, view3]
        let labels = [label1, label2, label3]
        let colors: [UIColor] = [.red, .green, .blue]
        
        for (index, view) in views.enumerated() {
            view.frame = CGRect(x: 50, y: 100 + index * 150, width: 200, height: 100)
            view.backgroundColor = colors[index]
            view.alpha = 0 // ซ่อน view ในตอนเริ่มต้น
            
            // ตั้งค่า Label
            let label = labels[index]
            label.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            label.textAlignment = .center
            label.textColor = .white
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.text = "Count: 0"
            view.addSubview(label)
            
            self.view.addSubview(view)
        }
    }
    
    // ฟังก์ชันสำหรับแสดง UIView ตาม queue
    func displayInQueue(id: Int) {
        displayQueue.async { [weak self] in
            guard let self = self else { return }
            
            // เพิ่มจำนวนครั้งที่ id นี้ถูกเรียกใช้
            if let count = self.idCount[id] {
                self.idCount[id] = count + 1
            } else {
                self.idCount[id] = 1
            }
            
            // ตรวจสอบว่ามี view ที่มี id ซ้ำอยู่แล้วหรือไม่
            if let index = self.viewMapping.firstIndex(where: { $0.id == id }) {
                var viewTuple = self.viewMapping[index]
                self.animateView(viewTuple.view, label: viewTuple.label, id: id, index: index, continueShowing: true)
            } else {
                // หา view ที่ยังว่างอยู่
                if let emptyIndex = self.viewMapping.firstIndex(where: { $0.id == nil }) {
                    self.viewMapping[emptyIndex] = ViewMapping(view: self.viewMapping[emptyIndex].view,
                                                               label: self.viewMapping[emptyIndex].label,
                                                               id: id,
                                                               timer: nil)
                    self.animateView(self.viewMapping[emptyIndex].view, label: self.viewMapping[emptyIndex].label, id: id, index: emptyIndex)
                } else {
                    // ถ้าไม่มี view ที่ว่างอยู่ ให้ใช้ view ตัวแรกใน queue
                    let firstViewTuple = self.viewMapping.removeFirst()
                    self.viewMapping.append(ViewMapping(view: firstViewTuple.view,
                                                        label: firstViewTuple.label,
                                                        id: id,
                                                        timer: nil))
                    self.animateView(firstViewTuple.view, label: firstViewTuple.label, id: id, index: self.viewMapping.count - 1)
                }
            }
        }
    }
    
    // ฟังก์ชันสำหรับการแสดงและจางหายของ UIView และอัปเดต Label พร้อมการจัดการ Timer
    private func animateView(_ view: UIView, label: UILabel, id: Int, index: Int, continueShowing: Bool = false) {
        DispatchQueue.main.async {
            // อัปเดต Label
            if let count = self.idCount[id] {
                label.text = "ID: \(id) Count: \(count)"
            }
            
            // ยกเลิก Timer เก่าถ้ามี
            self.viewMapping[index].timer?.invalidate()
            
            UIView.animate(withDuration: 0.3, animations: {
                view.alpha = 1.0 // แสดง view
            }) { _ in
                // สร้าง Timer ใหม่เมื่อไม่มีการเพิ่ม id ซ้ำ
                self.viewMapping[index].timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { _ in
                    UIView.animate(withDuration: 0.3, animations: {
                        view.alpha = 0.0 // ซ่อน view
                    }) { _ in
                        // รีเซ็ตค่า id และลบจำนวนครั้งของ id ออกจาก idCount
                        self.viewMapping[index].id = nil
                        self.viewMapping[index].timer = nil
                        self.idCount[id] = nil // ลบค่า id ออกจาก dictionary
                    }
                })
            }
        }
    }
}
