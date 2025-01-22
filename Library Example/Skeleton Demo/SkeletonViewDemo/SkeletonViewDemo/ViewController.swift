//
//  ViewController.swift
//  SkeletonViewDemo
//
//  Created by Dev on 8/1/2568 BE.
//

import UIKit
import Combine
import SkeletonView

class ViewController: UIViewController {

    @IBOutlet weak var dogTableView: UITableView!
    private var dogViewModel = DogViewModel()
    private var anyCancellabel: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dogTableView.showAnimatedGradientSkeleton()
    }
    
    private func setupBinding() {
        anyCancellabel = dogViewModel.$dogData
            .receive(on: DispatchQueue.main)
            .filter { dogData in
                return dogData != nil
            }
            .sink(receiveValue: { [weak self] _ in
                self?.dogTableView.stopSkeletonAnimation()
                self?.dogTableView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                self?.dogTableView.reloadData()
            })
        
        dogViewModel.fetchData()
    }
}

extension ViewController: SkeletonTableViewDelegate, SkeletonTableViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return SKTableViewCell.cellIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dogViewModel.dogData?.message.count ?? 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dogViewModel.dogData?.message.count ?? 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let haveCell = tableView.dequeueReusableCell(withIdentifier: SKTableViewCell.cellIdentifier, for: indexPath) as! SKTableViewCell
        haveCell.setupCell(url: dogViewModel.dogData?.message[indexPath.row])
        return haveCell
    }
}

