import UIKit

/// 화면 전체에서 공유하는 색 토큰.
/// 라이트/다크 두 값을 가진 다이나믹 컬러라 시스템 설정을 따라 자동으로 바뀐다.
struct CustomColor {
    // MARK: - Legacy (단계적으로 아래 토큰으로 교체 중)
    static let beige = UIColor(red: 255 / 255, green: 231 / 255, blue: 204 / 255, alpha: 1)
    static let sage = UIColor(red: 225 / 255, green: 238 / 255, blue: 221 / 255, alpha: 1)
    static let deepGreen = UIColor(red: 24 / 255, green: 58 / 255, blue: 29 / 255, alpha: 1)

    // MARK: - Design Tokens
    /// 전 화면 배경 (따뜻한 오프화이트)
    static let ground = dynamic(
        light: UIColor(red: 247 / 255, green: 245 / 255, blue: 240 / 255, alpha: 1),
        dark: UIColor(red: 22 / 255, green: 21 / 255, blue: 18 / 255, alpha: 1)
    )

    /// 카드·셀 표면
    static let surface = dynamic(
        light: .white,
        dark: UIColor(red: 31 / 255, green: 29 / 255, blue: 26 / 255, alpha: 1)
    )

    /// 본문 텍스트
    static let ink = dynamic(
        light: UIColor(red: 28 / 255, green: 27 / 255, blue: 26 / 255, alpha: 1),
        dark: UIColor(red: 242 / 255, green: 238 / 255, blue: 231 / 255, alpha: 1)
    )

    /// 주소·거리 등 보조 텍스트
    static let inkSoft = dynamic(
        light: UIColor(red: 138 / 255, green: 133 / 255, blue: 128 / 255, alpha: 1),
        dark: UIColor(red: 141 / 255, green: 135 / 255, blue: 125 / 255, alpha: 1)
    )

    /// 별점·주요 액션 강조 (남용하지 말 것)
    static let accent = dynamic(
        light: UIColor(red: 250 / 255, green: 158 / 255, blue: 51 / 255, alpha: 1),
        dark: UIColor(red: 245 / 255, green: 169 / 255, blue: 78 / 255, alpha: 1)
    )

    /// 진한 테두리 대신 쓰는 1px 헤어라인
    static let hairline = dynamic(
        light: UIColor.black.withAlphaComponent(0.06),
        dark: UIColor.white.withAlphaComponent(0.12)
    )

    // MARK: - Helper
    private static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        }
    }
}

/// 폰트 지정을 한곳에 모아 오타(대소문자 불일치)와 셀마다의 재생성을 막는다.
/// 등록된 파일명은 Recipekorea.ttf / BlackHanSans-Regular.ttf / S-CoreDream-4Regular.otf
enum AppFont {
    private static func custom(_ name: String, _ size: CGFloat, fallback: UIFont) -> UIFont {
        UIFont(name: name, size: size) ?? fallback
    }

    /// 화면 타이틀 등 가장 큰 표시용
    static func display(_ size: CGFloat) -> UIFont {
        custom("BlackHanSans-Regular", size, fallback: .systemFont(ofSize: size, weight: .bold))
    }

    /// 가게 이름, 메뉴 항목 등
    static func title(_ size: CGFloat) -> UIFont {
        custom("Recipekorea", size, fallback: .systemFont(ofSize: size, weight: .semibold))
    }

    /// 주소, 전화번호 등 본문
    static func body(_ size: CGFloat) -> UIFont {
        custom("S-CoreDream-4Regular", size, fallback: .systemFont(ofSize: size))
    }

    // MARK: - 자주 쓰는 고정 크기
    static let navigationTitle = display(24)
    static let barButton = title(16)
    static let storeName = title(16)
    static let cardName = title(12)
    /// 접근성 최소 권장(11pt)을 넘도록 12pt 사용
    static let actionLabel = title(12)
    static let address = body(12)
    static let caption = body(13)
}
