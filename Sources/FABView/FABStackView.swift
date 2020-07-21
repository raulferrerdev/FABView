//  Copyright (c) 2020 Raúl Ferrer
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
//  OR OTHER DEALINGS IN THE SOFTWARE.
//  
//
//  Created by RaulF on 16/04/2020.
//

import UIKit


class FABStackView: UIStackView {

    private var fabSecondaryButtons: [FABSecondary] = [FABSecondary]()
    private var secondaryButtons: [UIView] = [UIView]()
    private var secondaryViews: [UIView] = [UIView]()

    weak var delegate: FABSecondaryButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureStackView()
    }
    
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configureStackView() {
        translatesAutoresizingMaskIntoConstraints = false
        distribution = .fill
        axis = .vertical
        alignment = .trailing
        spacing = 12
        clipsToBounds = true
    }
    
    
    private func configureSecondaryButtons() {
        for secondary in fabSecondaryButtons {
            let secondaryView = FABSecondaryButton(fabSecondary: secondary)
            secondaryView.delegate = self
            secondaryViews.append(secondaryView)
        }
        
        setSecondaryButtonsArray()
    }
    
    
    private func setSecondaryButtonsArray() {
        for view in secondaryViews {
            secondaryButtons.append(view)
        }
    }
}


// MARK: - Public methods
extension FABStackView {
    func addSecondaryButtonWith(image: UIImage, labelTitle: String, action: @escaping () -> ()) {
        let component: FABSecondary
        component.image = image
        component.title = labelTitle
        component.action = action
        fabSecondaryButtons.append(component)
    }
    
    
    func setFABButton() {
        configureSecondaryButtons()
    }
    
    
    func showButtons() {
        guard let view = secondaryButtons.last else {
            setSecondaryButtonsArray()
            return
        }
        
        secondaryButtons.removeLast()
        
        addArrangedSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        view.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
        UIView.animate(withDuration: 0.075, animations: {
            view.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
        }) { finished in
            UIView.animate(withDuration: 0.03, animations: {
                view.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
            }) { finished in
                UIView.animate(withDuration: 0.03, animations: {
                    view.transform = CGAffineTransform.identity
                }) { finished in
                    self.showButtons()
                }
            }
        }
    }
    
    
    func dismissButtonsWithReset(_ reset: Bool) {
        guard !reset else {
            secondaryViews.removeAll()
            secondaryButtons.removeAll()
            fabSecondaryButtons.removeAll()
            
            subviews.forEach({ $0.removeFromSuperview() })
            return
        }
        
        guard let view = secondaryButtons.last else {
            if reset {
                secondaryViews.removeAll()
                secondaryButtons.removeAll()
                fabSecondaryButtons.removeAll()
                subviews.forEach({ $0.removeFromSuperview() })
            } else {
                setSecondaryButtonsArray()
            }
            return
        }
        
        secondaryButtons.removeLast()
        
        UIView.animate(withDuration: 0.075, animations: {
            view.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
        }) { finished in
            view.removeFromSuperview()
            self.dismissButtonsWithReset(reset)
        }
    }
    
    
    func resetFABButton() {
        dismissButtonsWithReset(true)
    }
}


extension FABStackView: FABSecondaryButtonDelegate {
    func secondaryActionForButton(_ action: @escaping () -> ()) {
        delegate?.secondaryActionForButton(action)
        dismissButtonsWithReset(false)
    }
}

