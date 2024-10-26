# Weather
OpenWeather API 를 사용한 날씨 앱

## 프로젝트 환경
- 인원: 1명
- 기간: 2024.10.14 - 2024.09.01
- 버전: iOS 16+

## 기술 스택
- iOS: UIKit, MapKit, RxSwift
- Architecture: MVVM + Input/Output, Singleton
- Network: Alamofire, Router
- UI: CodebaseUI, SnapKit, RxDataSources
- ETC: Toast

## 핵심 기능
- 도시 리스트 제공
- 도시에 따른 날씨정보 제공
  
## 고려 사항
### OpenWeather API 요청에 대한 고려
- OpenAPI의 `units` 값을 요청인자로 전달하여 섭씨온도 기준 온도 조회
- OpenAPI의 `lang` 값을 요청인자로 전달하여 한국어로 변환된 날씨 상태 조회
- OpenAPI의 응답 중 `weather condition code` 를 사용하여 배경이미지가 날씨에 맞게 변화되도록 설정
- OpenAPI의 응답 중 `icon`을 enum을 사용하여 낮밤 상관없이 아이콘 출력되도록 설정
  
### 사용자 편의성 및 오류 사항에 대한 고려
- `localizedCaseInsensitiveContains` 옵션을 사용하여 대소문자 구분 없이 검색 가능하도록 설정
- 네트워크 실패 시 Toast 메시지 출력되도록 구현
- Json 디코딩 실 패 시 Toast 메시지 출력되도록 구현
