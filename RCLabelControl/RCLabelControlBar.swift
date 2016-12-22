//
//  RCLabelControlBar.swift
//  RCLabelControl
//
//  Created by Developer on 2016/10/17.
//  Copyright © 2016年 Beijing Haitao International Travel Service Co., Ltd. All rights reserved.
//

import UIKit

public typealias RCLabelControlBarItemSelectedCallback = (_ index: Int) -> Void

let DEFAULT_SLIDER_COLOR = UIColor.orange
let SLIDER_VIEW_HEIGHT: CGFloat = 2


public class RCLabelControlBar: UIView, RCLabelControlBarItemDelegate {

    public  var itemTitles: [String]! {
        didSet {
            setupItems()
        }
    }
    public var itemColor: UIColor! {
        didSet {
            for i in 0..<items.count {
                let item = items[i]
                item.color = itemColor
            }
        }
    }

    /// 滑动指示标志
    private var sliderView: UIView!

    /// 选中的颜色
    public var itemSelectedColor: UIColor! {
        didSet {
            for i in 0..<items.count {
                let item = items[i]
                item.selectedColor = itemSelectedColor
            }
        }
    }

    /// slider view 的颜色
    public var sliderColor: UIColor!

    /// 选中的Item 的 位置
    public var selectedIndex: Int {
        get {
            return items.index(of: selectedItem)!
        }
    }

    /// item 的宽度均等
    public var isWidthEqualy: Bool = false

    /// contentview
    private var scrollView: UIScrollView!

    /// 条目
    private var items: [RCLabelControlBarItem]!

    /// 选中的条目
    private var selectedItem: RCLabelControlBarItem! {
        willSet(newValue) {
            if selectedItem != nil {
                selectedItem.selected = false
            }
        }
        didSet {
            selectedItem.selected = true
        }
    }

    /// 条目点击回调
    private var callback: RCLabelControlBarItemSelectedCallback!

    // MARK: - lifecicle
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        self.backgroundColor = .white
        items = [RCLabelControlBarItem]()
        setupScrollView()
        setupSliderView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }

    // MARK: - Public
    public func barItemSelected(closure: @escaping RCLabelControlBarItemSelectedCallback) -> Void {
        callback = closure
    }

    public func selectBarItem(index: Int) -> Void {
        let item = items[index]
        let currentIndex = items.index(of: selectedItem)
        if item == selectedItem {
            return
        }
        let duration: TimeInterval = 0.25 + Double(abs(index - currentIndex!)) * 0.1
        item.selected = true
        scrollToVisibleItem(item: item)
        addAnimationOnSelectedItem(item: item, duration: duration)
        selectedItem = item
    }


    // MARK: - Custom Accessors
    func setItemSelectedColor(color: UIColor) {

    }

    func setSliderColor(color: UIColor) {
        sliderColor = color
        sliderView.backgroundColor = color
    }


    // MARK: - Private method
    fileprivate func setupScrollView() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
    }

    fileprivate func setupSliderView() {
        sliderView = UIView()
        sliderColor = DEFAULT_SLIDER_COLOR
        sliderView.backgroundColor = sliderColor
        scrollView.addSubview(sliderView)
    }

    fileprivate func setupItems() {
        var itemX:CGFloat = 0
        for it in items {
            it.removeFromSuperview()
        }
        items.removeAll()
        let equalWidth:CGFloat = frame.width/CGFloat(itemTitles.count)
        for i in 0..<itemTitles.count {
            let item = RCLabelControlBarItem()
            item.delegate = self
            //set up current item's frame
            let title = itemTitles[i]
            let itemWidth = RCLabelControlBarItem.widthForTitle(title: title)
            item.title = title
            item.frame = CGRect(x: itemX, y: 0, width: itemWidth, height: scrollView.frame.size.height)
            items.append(item)
            itemX = item.frame.maxX
            scrollView.addSubview(item)
        }

        if isWidthEqualy && itemX <= frame.width {
            scrollView.contentSize = CGSize(width: frame.width , height: scrollView.frame.height)
            for i in 0..<itemTitles.count {
                let item = items[i]
                item.center = CGPoint(x: CGFloat(Double(i)+0.5)*equalWidth, y: item.center.y)
            }
        }else {
            scrollView.contentSize = CGSize(width: itemX , height: scrollView.frame.height)
        }

        if (scrollView.contentSize.width < self.frame.width) {
            let width = scrollView.contentSize.width
            let x = (self.frame.width - scrollView.contentSize.width) / 2
            scrollView.contentInset = UIEdgeInsetsMake(0, x, 0, -x)
            scrollView.frame = CGRect(x: x, y: 0, width: width , height: scrollView.frame.size.height)
        } else {
            scrollView.frame = CGRect(x: 0, y: 0, width:self.frame.width, height: scrollView.frame.size.height)
            scrollView.contentInset = .zero
            scrollView.center = self.center
        }

        // set the default selected item, the first default
        let firstItem = self.items.first
        firstItem?.selected = true
        selectedItem = firstItem

        //set frame of sliderView by selected item
        sliderView.frame = CGRect(x: firstItem!.frame.minX+12, y: self.frame.size.height - SLIDER_VIEW_HEIGHT, width: firstItem!.frame.size.width-24, height: SLIDER_VIEW_HEIGHT)
    }

    fileprivate func scrollToVisibleItem(item:RCLabelControlBarItem) {
        let selectedItemIndex = items.index(of: selectedItem)
        let visibleItemIndex = items.index(of: item)
        if selectedItemIndex == visibleItemIndex {
            return
        }
        var offset = scrollView.contentOffset
        // If the item to be visible is in the screen, nothing to do
        if item.frame.minX >= offset.x && item.frame.maxX <= (offset.x + scrollView.frame.size.width) {
            return
        }

        // Update the scrollView's contentOffset according to different situation
        if (selectedItemIndex! < visibleItemIndex!) {
            // The item to be visible is on the right of the selected item and the selected item is out of screeen by the left, also the opposite case, set the offset respectively
            if (selectedItem.frame.maxX < offset.x) {
                offset.x = item.frame.minX
            } else {
                offset.x = item.frame.maxX - scrollView.frame.size.width
            }
        } else {
            // The item to be visible is on the left of the selected item and the selected item is out of screeen by the right, also the opposite case, set the offset respectively
            if selectedItem.frame.minX > (offset.x + scrollView.frame.size.width) {
                offset.x = item.frame.maxX - scrollView.frame.size.width
            } else {
                offset.x = item.frame.minX
            }
        }
        scrollView.contentOffset = offset;
    }

    fileprivate func addAnimationOnSelectedItem(item: RCLabelControlBarItem, duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations:{
            var rect = self.sliderView.frame
            rect.origin.x = item.frame.minX+12
            rect.size.width = item.frame.width-24
            self.sliderView.frame = rect
        })
    }

    // MARK: - Bar Item Delegate
    func barSelected(item: RCLabelControlBarItem) {
        if item == selectedItem {
            return
        }
        scrollToVisibleItem(item: item)
        addAnimationOnSelectedItem(item: item, duration: 0.25)
        selectedItem = item
        if self.callback != nil {
            callback(items.index(of: item)!)
        }
    }

}


protocol RCLabelControlBarItemDelegate {
    func barSelected(item: RCLabelControlBarItem) -> Void
}

let DEFAULT_TITLE_FONTSIZE = CGFloat(13)
let DEFAULT_TITLE_SELECTED_FONTSIZE = CGFloat(14)
let DEFAULT_TITLE_COLOR = UIColor.darkGray
let DEFAULT_TITLE_SELECTED_COLOR = UIColor.orange
let HORIZONTAL_MARGIN: CGFloat = 10

class RCLabelControlBarItem: UIView {
    fileprivate  var selected: Bool! {
        didSet {
            //value changed, color & font also change
            setNeedsDisplay()
        }
    }
    fileprivate  var delegate: RCLabelControlBarItemDelegate?

    fileprivate var title: String! {
        didSet {
            setNeedsDisplay()
        }
    }
    fileprivate var fontSize: CGFloat! {
        didSet {
            setNeedsDisplay()
        }
    }
    fileprivate var selectedFontSize: CGFloat! {
        didSet{
            setNeedsDisplay()
        }
    }
    fileprivate  var color: UIColor! {
        didSet{
            setNeedsDisplay()
        }
    }

    fileprivate var selectedColor: UIColor! {
        didSet{
            setNeedsDisplay()
        }
    }


    fileprivate init() {
        super.init(frame:CGRect(x:0, y:0, width:0, height:0))
        self.fontSize = DEFAULT_TITLE_FONTSIZE
        self.selectedFontSize = DEFAULT_TITLE_SELECTED_FONTSIZE
        self.color = DEFAULT_TITLE_COLOR
        self.selectedColor = DEFAULT_TITLE_SELECTED_COLOR
        self.selected = false
        self.backgroundColor = .clear
    }

    required  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override  func draw(_ rect: CGRect) {
        let size = self.frame.size
        let titleX = (size.width - titleSize().width) * 0.5
        let titleY = (size.height - titleSize().height) * 0.5
        let titleRect = CGRect(x: titleX, y: titleY, width: titleSize().width, height: titleSize().height)
        let attributes = [NSFontAttributeName : titleFont(), NSForegroundColorAttributeName: titleColor()]
        let str = NSString(string: title!)
        str.draw(in: titleRect, withAttributes: attributes)
    }

    // MARK: - Private
    private func titleSize() -> CGSize {
        let attributes = [NSFontAttributeName: titleFont()]
        let str = NSString(string: self.title!)
        var size = str.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
        size.width = ceil(size.width)
        size.height = ceil(size.height)
        return size
    }

    private func titleFont() -> UIFont {
        var font: UIFont
        if self.selected! {
            font = UIFont.boldSystemFont(ofSize: self.selectedFontSize)
        } else {
            font = UIFont.systemFont(ofSize: self.fontSize)
        }
        return font
    }

    private func titleColor() -> UIColor {
        var color: UIColor
        if self.selected! {
            color = self.selectedColor
        } else {
            color = self.color
        }
        return color
    }

    // MARK: - Public Class Method

    class func widthForTitle(title: String) -> CGFloat {
        let attributes = [ NSFontAttributeName : UIFont.systemFont(ofSize: DEFAULT_TITLE_FONTSIZE)]
        let str = NSString(string: title)
        var size = str.boundingRect(with: CGSize(width:CGFloat(MAXFLOAT), height:CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil).size
        size.width = ceil(size.width) + HORIZONTAL_MARGIN * 2
        return size.width
    }

    // MARK: - Responder
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.selected = true
        if (self.delegate != nil) {
            self.delegate!.barSelected(item: self)
        }
    }
}
