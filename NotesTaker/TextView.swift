//
//  TextView.swift
//  NotesTaker
//
//  Created by Mark Cornelisse on 20/06/2020.
//  Copyright © 2020 JOSEF RICHTER. All rights reserved.
//

import Combine
import SwiftUI

struct TextView: NSViewRepresentable {
    @Binding var text: String
    var isEditable: Bool = true
    var font: NSFont?    = .systemFont(ofSize: 14, weight: .regular)
    
    var onEditingChanged: () -> Void = {}
    var onCommit : () -> Void = {}
    var onTextChange : (String) -> Void = { _ in }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> CustomTextView {
        let textView = CustomTextView(text: text, isEditable: isEditable, font: font)
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateNSView(_ view: CustomTextView, context: Context) {
        view.text = text
        view.selectedRanges = context.coordinator.selectedRanges
    }
}

#if DEBUG
struct MacEditorTextView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TextView(text: .constant("{ \n    planets { \n        name \n    }\n}"), isEditable: true, font: .userFixedPitchFont(ofSize: 14))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
            
            TextView(text: .constant("{ \n    planets { \n        name \n    }\n}"), isEditable: false)
                .environment(\.colorScheme, .light)
                .previewDisplayName("Light Mode")
        }
    }
}
#endif

extension TextView {
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: TextView
        var selectedRanges: [NSValue] = []
        
        init(_ parent: TextView) {
            self.parent = parent
            super.init()
        }
        
        // MARK: NSTextViewDelegate
        
        func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.parent.onEditingChanged()
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
        }
        
        func textDidEndEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.parent.onCommit()
        }
        
        // MARK: NSObject
    }
}

final class CustomTextView: NSView {
    private var isEditable: Bool
    private var font: NSFont?
    
    weak var delegate: NSTextViewDelegate?
    
    var text: String {
        didSet {
            textView.string = text
        }
    }
    
    var selectedRanges: [NSValue] = [] {
        didSet {
            guard selectedRanges.count > 0 else {
                return
            }
            textView.selectedRanges = selectedRanges
        }
    }
    
    private lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = true
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalRuler = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    private lazy var textView: NSTextView = {
        let contentSize = scrollView.contentSize
        let textStorage = NSTextStorage()
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(containerSize: scrollView.frame.size)
        textContainer.widthTracksTextView = true
        textContainer.containerSize = NSSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        
        layoutManager.addTextContainer(textContainer)
        
        let textView = NSTextView(frame: .zero, textContainer: textContainer)
        textView.autoresizingMask = .width
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.delegate = self.delegate
        textView.drawsBackground = true
        textView.font = self.font
        textView.isEditable = self.isEditable
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize = NSSize(width: 0, height: contentSize.height)
        textView.textColor = .labelColor
        
        return textView
    }()
    
    init(text: String, isEditable: Bool, font: NSFont?) {
        self.font = font
        self.isEditable = isEditable
        self.text = text
        
        super.init(frame: .zero)
    }
    
    func setupScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
    
    func setupTextView() {
        scrollView.documentView = textView
    }
    
    // MARK: NSView
    
    override func viewWillDraw() {
        super.viewWillDraw()
        
        setupScrollViewConstraints()
        setupTextView()
    }
    
    // MARK: NSCoding
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: NSResponder
    
    // MARK: NSObject
}
