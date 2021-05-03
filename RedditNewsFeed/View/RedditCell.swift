//
//  RedditCell.swift
//  Reddit NewsFeed
//
//  Created by Sandeep Kumar on  01/05/21.
//

import UIKit
import Kingfisher

struct RedditCellRowViewModel {}

class RedditCell: UITableViewCell {
    // MARK: - Properties

    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    var flagImageView = UIImageView()
    let nameLabel = UILabel()
    let commentLabel = UILabel()
    let scoreLabel = UILabel()
    var heightConstraint: NSLayoutConstraint!

    // MARK: - Life Cycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func setupView() {
        contentView.addSubview(containerView) {
            $0.edges.pinToSuperview(insets: .init(top: 14, left: 10, bottom: 0, right: 10))
        }
        
        nameLabel.numberOfLines = 0
        nameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)

        containerView.addSubview(nameLabel) {
            $0.leading.pinToSuperview(inset: 20)
            $0.trailing.pinToSuperview(inset: 20)
            $0.top.pinToSuperview(inset: 20)
        }

        flagImageView.contentMode = .scaleAspectFit
        flagImageView.backgroundColor = UIColor(red: 238.0/255.0,
                                                green: 237.0/255.0,
                                                blue: 242.0/255.0,
                                                alpha: 1)
        containerView.addSubview(flagImageView) {
            $0.leading.pinToSuperview(inset: 20)
            $0.trailing.pinToSuperview(inset: 20)
            $0.top.align(with: nameLabel.al.bottom + 10)
            heightConstraint = $0.height.set(400)
        }
        
        containerView.addSubview(commentLabel) {
            $0.leading.pinToSuperview(inset: 20)
            $0.trailing.pinToSuperview(inset: 20)
            $0.top.align(with: flagImageView.al.bottom + 10)
            $0.bottom.pinToSuperview(inset: 20)
            $0.height.set(20)
        }

        containerView.addSubview(scoreLabel) {
            $0.trailing.pinToSuperview(inset: 20)
            $0.top.align(with: commentLabel.al.top)
            $0.height.set(20)
        }
        
        backgroundColor = .lightGray
    }
}

// MARK: - ViewConfigurable
var heightDic: [String: Double] = [:]

extension RedditCell {
    func configure(with viewModel: RedditRootViewModel) {
        nameLabel.text = viewModel.title
        if let comment = viewModel.commentNumber {
            commentLabel.text = "Comment: \(comment)"
        }
        if let score = viewModel.score {
            scoreLabel.text = "Score: \(score)"
        }
        
        let width: Double = Double(flagImageView.bounds.width)
        let tempVal = CGFloat(viewModel.aspectRatio * width)
        let height = (tempVal > 0) ?  tempVal : self.heightConstraint.constant
        self.heightConstraint.constant = CGFloat(height)
        flagImageView.kf.setImage(with: viewModel.imageURL, placeholder: UIImage(imageLiteralResourceName: "placeholder")) { result in

        }
    }
}

