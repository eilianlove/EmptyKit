//
//  EmptyView.swift
//  EmptyKit
//
//  Created by archerzz on 16/11/7.
//  Copyright © 2016年 archerzz. All rights reserved.
//

import UIKit

/// EmptyView
final class EmptyView: UIView {
    
    // MARK: - Internal Properties
    var customView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            guard let customView = customView else {
                return
            }
            customView.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(customView)
        }
    }
    
    var verticalOffset: CGFloat = 0
    var verticalSpace: CGFloat = 0
    var horizontalSpace: CGFloat = 0
    var minimumButtonWidth: CGFloat? = nil
    var fadeInOnDisplay: Bool = true
    
    // Events
    
    var didTappedEmptyView:((UIView) -> Void)?
    var didTappedButton:((UIButton) -> Void)?
    
    // MARK: - Lazy Properties
    lazy var contentView: UIView = { [unowned self] in
        let newView = UIView()
        newView.translatesAutoresizingMaskIntoConstraints = false
        newView.backgroundColor = UIColor.clear
        newView.isUserInteractionEnabled = true
        newView.alpha = 0
        return newView
    }()
    
    lazy var titleLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.autoresizingMask = [.flexibleWidth]
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 27)
        label.textColor = UIColor(white: 0.6, alpha: 1)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.accessibilityLabel = "empty set title"
        return label
    }()
    
    lazy var detailLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor(white: 0.6, alpha: 1)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.accessibilityLabel = "empty set detail label"
        return label
    }()
    
    lazy var imageView: UIImageView = { [unowned self] in
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.accessibilityIdentifier = "empty set background image"
        return imageView
    }()
    
    lazy var button: UIButton = { [unowned self] in
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.accessibilityIdentifier = "empty set button"
        button.addTarget(self, action: #selector(EmptyView.didTapButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    init() {
        super.init(frame: CGRect.zero)
        addSubview(contentView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapEmptyView(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("archerzz: ", #function, #line, type(of: self))
    }
    
    // MARK: - Override
    public override  func didMoveToSuperview() {
        guard fadeInOnDisplay == true else {
            self.contentView.alpha = 1
            return
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.contentView.alpha = 1
        })
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else {
            return nil
        }
        if hitView.isKind(of: UIControl.classForCoder()) {
            return hitView
        }
        if hitView.isEqual(self.contentView) || hitView.isEqual(customView) {
            return hitView
        }
        return nil
    }
    
}

// MARK: - Internal
internal extension EmptyView {
    
    func prepareForReuse() {
        self.contentView.subviews.forEach {
            $0.removeFromSuperview()
        }
        self.removeAllConstraints()
    }
    
}

// MARK: - Constraints
private extension EmptyView {
    
    func removeAllConstraints() {
        self.removeConstraints(self.constraints)
        contentView.removeConstraints(self.contentView.constraints)
    }
    
}


// MARK: - Setup
internal extension EmptyView {
    
    func setupConstraints() {
        let space = self.verticalSpace
        let metrics = ["padding": horizontalSpace]
        var views:[String: UIView] = [:]
        var names:[String] = []
        self.addEquallyRelatedConstraint(with: contentView, attribute: .centerX)
        let centerY = self.addEquallyRelatedConstraint(with: contentView, attribute: .centerY)
        self.addConstraints(withVisualFormat: "|[contentView]|", metrics: nil, views: ["contentView": contentView])
        
        // When a custom offset is available, we adjust the vertical constraints' constants
        if verticalOffset != 0 {
            centerY.constant = verticalOffset
        }
        
        if let customView = customView {
            self.addConstraints(withVisualFormat: "V:|[contentView]|", metrics: nil, views: ["contentView": contentView])
            contentView.addConstraints(withVisualFormat: "H:|[customView]|", metrics: nil, views: ["customView": customView])
            contentView.addConstraints(withVisualFormat: "V:|[customView]|", metrics: nil, views: ["customView": customView])
        }
        
        // Assign the image view's horizontal constraints
        if self.canShowImage {
            contentView.addSubview(imageView)
            let name = "imageView"
            names.append(name)
            views[name] = imageView
            contentView.addEquallyRelatedConstraint(with: imageView, attribute: .centerX)
        }
        // Assign the title label's horizontal constraints
        if self.canShowTitle {
            contentView.addSubview(titleLabel)
            let name = "titleLabel"
            names.append(name)
            views[name] = titleLabel
            contentView.addConstraints(withVisualFormat: "|-(>=padding@800)-[\(name)]-(>=padding@800)-|", metrics: metrics, views: views)
            contentView.addEquallyRelatedConstraint(with: titleLabel, attribute: .centerX)
        }
        
        // Assign the detail label's horizontal constraints
        if self.canShowDetail {
            contentView.addSubview(detailLabel)
            let name = "detailLabel"
            names.append(name)
            views[name] = detailLabel
            contentView.addConstraints(withVisualFormat: "|-(>=padding@800)-[\(name)]-(>=padding@800)-|", metrics: metrics, views: views)
            contentView.addEquallyRelatedConstraint(with: detailLabel, attribute: .centerX)
        }
        
        // Assign the button's horizontal constraints
        if self.canShowButton {
            contentView.addSubview(button)
            let name = "button"
            names.append(name)
            views[name] = button
            let buttonVFL: String
            if let minimumButtonWidth = minimumButtonWidth {
                buttonVFL = name + "(>=\(minimumButtonWidth))"
            } else {
                buttonVFL = name
            }
            contentView.addConstraints(withVisualFormat: "|-(>=padding@800)-[\(buttonVFL)]-(>=padding@800)-|", metrics: metrics, views: views)
            contentView.addEquallyRelatedConstraint(with: button, attribute: .centerX)
        }
        
        // Complete verticalFormat
        var verticalFormat = ""
        for i in 0..<names.count {
            let name = names[i]
            verticalFormat += "[\(name)]"
            if (i < views.count - 1) {
                verticalFormat += "-(\(space)@800)-"
            }
        }
        
        // Assign the vertical constraints to the content view
        if (verticalFormat.characters.count > 0) {
            contentView.addConstraints(withVisualFormat: "V:|\(verticalFormat)|", metrics: metrics, views: views)
        }
    }
    
}

// MARK: - Private Computed Properties
private extension EmptyView {
    
    var canShowImage: Bool {
        return (self.imageView.image != nil)
    }
    
    var canShowTitle: Bool {
        return (self.titleLabel.attributedText?.length ?? 0 > 0)
    }
    
    var canShowDetail: Bool {
        return (self.detailLabel.attributedText?.length ?? 0 > 0)
    }
    
    var canShowButton: Bool {
        if self.button.attributedTitle(for: .normal)?.string.lengthOfBytes(using: .unicode) ?? 0 > 0 ||
            self.button.image(for: .normal) != nil {
            return true
        }
        return false
    }
    
}

// MARK: - Actions
private extension EmptyView {
    
    @objc func didTapButton(_ button: UIButton) {
        didTappedButton?(button)
    }
    
    @objc func didTapEmptyView(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else {
            return
        }
        didTappedEmptyView?(view)
    }
    
}

// MARK: - UIView extension
private extension UIView {
    
    func addConstraints(withVisualFormat format: String, metrics: [String : Any]?, views: [String : Any]) {
        let noLayoutOptions = NSLayoutFormatOptions(rawValue: 0)
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: format, options: noLayoutOptions, metrics: metrics, views: views)
        self.addConstraints(constraints)
    }
    
    @discardableResult
    func addEquallyRelatedConstraint(with view: UIView, attribute: NSLayoutAttribute) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view, attribute: attribute, relatedBy: .equal, toItem: self, attribute: attribute, multiplier: 1, constant: 0)
        self.addConstraint(constraint)
        return constraint
    }
}

















