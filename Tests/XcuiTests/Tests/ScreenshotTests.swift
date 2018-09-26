import MixboxUiTestsFoundation
import MixboxIpc
import XCTest
import MixboxFoundation
import CocoaImageHashing

class ScreenshotTests: TestCase {
    func test() {
        openScreen(name: "ScreenshotTestsView")
        
        pageObjects.screen.view(index: 0).assert.isDisplayed()
        
        for index in 0..<ScreenshotTestsConstants.viewsCount {
            let imageOrNil = UIImage.image(
                color: ScreenshotTestsConstants.color(index: index),
                size: ScreenshotTestsConstants.viewSize(index: index)
            )
            guard let image = imageOrNil else {
                XCTFail("Can not create image")
                return
            }
            pageObjects.screenXcui.view(index: index).withoutTimeout.assert.matchesReference(image: image)
            pageObjects.screen.view(index: index).withoutTimeout.assert.matchesReference(image: image)
        }
    }
    
    func test_1() {
        let hashing = OSImageHashing.sharedInstance()
        
        let images = ["cat_size", "cat_text", "cat_color", "cat", "cat_aspect", "cat_borders", "cat_not_cat"]
        
        print("-\t\(images.joined(separator: "\t"))")
        
        for a in images {
            print("\(a)", terminator: "")
            for b in images {
                let image0 = UIImage(named: a, in: Bundle(for: type(of: self)), compatibleWith: nil)!
                let image1 = UIImage(named: b, in: Bundle(for: type(of: self)), compatibleWith: nil)!
                let dist = hashing.hashDistance(
                    hashing.hashImage(image0, with: .aHash),
                    to: hashing.hashImage(image1, with: .aHash)
                )
                print("\t\(dist)", terminator: "")
            }
            print()
        }
    }
}

private final class Screen: BasePageObjectWithDefaultInitializer {
    func view(index: Int) -> ViewElement {
        let id = ScreenshotTestsConstants.viewId(index: index)
        return element(id) { element in element.id == id }
    }
}

private extension PageObjects {
    var screen: Screen {
        return pageObject()
    }
    var screenXcui: Screen {
        return apps.mainXcui.pageObject()
    }
}
