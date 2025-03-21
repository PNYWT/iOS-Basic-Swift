import UIKit
import SnapKit

struct SettingModel {
    var section: String
    var itemRow: [String]
}

class ViewController: UIViewController {
    
    private lazy var scrollView: UIScrollView = {
        let scv = UIScrollView()
        scv.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1)
        scv.isUserInteractionEnabled = true
        scv.isScrollEnabled = true
        return scv
    }()
    
    private lazy var viewTop: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = 0
        view.backgroundColor = .clear
        return view
    }()
    
    private var heightForRow = 51.0
    private var sizeColor = 30.0
    private var heightHeaderTable = 70.0
    private lazy var tableViewType: UITableView = {
        let tableview = UITableView(frame: .zero, style: .plain)
        tableview.register(TypeDateTableViewCell.self, forCellReuseIdentifier: TypeDateTableViewCell.cellIndentifier)
        tableview.separatorStyle = .none
        tableview.dataSource = self
        tableview.delegate = self
        tableview.backgroundColor = .clear
        tableview.estimatedRowHeight = heightForRow
        tableview.sectionHeaderHeight = 0.0
        tableview.isScrollEnabled = false
        tableview.showsVerticalScrollIndicator = false
        tableview.showsHorizontalScrollIndicator = false
        return tableview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        stackView.addArrangedSubview(viewTop)
        viewTop.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        
        stackView.addArrangedSubview(tableViewType)
        tableViewType.snp.makeConstraints { make in
            make.height.equalTo(0.1)
        }
        tableViewType.reloadData()
    }
    
    @MainActor
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableViewType.snp.updateConstraints { make in
            make.height.equalTo(tableViewType.contentSize.height)
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TypeDateTableViewCell.cellIndentifier, for: indexPath) as? TypeDateTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        print("indexPath -> \(indexPath.row)")
        cell.setupContent(indexPath: indexPath)
        return cell
    }
}
