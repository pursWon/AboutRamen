# AboutRamen
현재 위치를 기반으로 주변 라멘 가게를 검색하는 앱

**앱 스토어 링크** : [어바웃라멘](https://apps.apple.com/kr/app/%EC%96%B4%EB%B0%94%EC%9B%83%EB%9D%BC%EB%A9%98/id6446753603)


<div align="center">

[동영상](https://github.com/pursWon/AboutRamen/assets/99719661/d09492b7-723c-423e-ac9e-27ea8302456c)

</div>

## 기능명세서 표 및 공수산정
- 1월 8일부터 3월말까지 목표를 잡고 공수산정을 하였습니다.    
- 화면별로 기능을 정의하고 명세하였습니다.   
- 우선순위를 정하여 우선순위가 낮은 것부터 오름차순으로 진행하였습니다.   

<img width="600" src="https://user-images.githubusercontent.com/99719661/225807620-7f110a93-5404-455e-884e-4dab3b0bfea6.png">
<img width="600" src="https://user-images.githubusercontent.com/99719661/225807651-27d6e410-3e18-4f07-b109-a618485da10a.png">
<img width="600" src="https://user-images.githubusercontent.com/99719661/225807670-58cf68d6-f943-49f1-b6f9-b14d031e4d9d.png">
<img width="600" src="https://user-images.githubusercontent.com/99719661/225807685-75627a75-8eef-46d0-9859-e84ebe5f2363.png">

<br/>

## 사용한 API

- Kakao Map

## 사용한 라이브러리

- Alamofire
- Realm
- KingFisher

## 화면별 기능 요약

### 1. 홈 화면 

<img src="https://user-images.githubusercontent.com/99719661/229824737-72e3947e-700b-46f8-b9fa-d898f5fc38e3.png" width="25%" height="25%" />

- 지역 위치에 해당되는 라멘 가게들을 보여줍니다.
- 가게에 매겨진 별점을 보여줍니다. 
- 지역 변경 버튼을 통하여 다른 지역의 라멘 가게들을 볼 수 있습니다.

<br/>

### 2. 지역 변경 화면 

<img src = "https://user-images.githubusercontent.com/99719661/229829841-5b0c6b74-1073-4d60-b936-2fa43004d193.png" width="25%" height="25%" />

- 전국에 있는 여러개의 지역 중 하나를 지정할 수 있습니다.
- 홈 화면으로 보낸 지역을 기반으로 새로 선정된 가게들을 홈 화면에서 보여줍니다.
- picker를 통해 지역을 설정하여 위도, 경도를 변경 가능 → 좌표에 맞는 가게 데이터들을 불러옵니다.

<br/>

### 3. 가게 정보 화면 

<img src = "https://user-images.githubusercontent.com/99719661/229831768-6ea9616c-9864-4b3d-a67c-f9d91d8e1bb8.png" width="25%" height="25%" />

- 가게의 좋아요, 리뷰, 나의 라멘 가게 여부를 보여줍니다.
- 가게의 별점을 매길 수 있습니다.
- 좋아요, 나의 라멘 가게 버튼이 눌려져 있으면 다시 누름에 따라 취소할 수 있습니다. 
- 가게에 대한 리뷰를 남길 수 있습니다.
- 나의 라멘 가게 목록에 추가할 수 있습니다. 
- 가게에 해당되는 이미지를 보여줍니다. 
- 링크 버튼을 누르면 가게 링크로 이동합니다. 
- 가게의 주소, 전화번호를 보여줍니다. 

<br/>

### 4. 리뷰 화면

<img src = "https://user-images.githubusercontent.com/99719661/229836431-67bd529a-c785-48bb-afd8-be221814cf68.png" width="25%" height="25%" />

- 리뷰를 남길 수 있습니다. 
- 리뷰 내용이 없을 시에 내용을 추가해달라는 알림이 나타납니다.

<br/>

### 5. 목록 화면
<img src="https://user-images.githubusercontent.com/99719661/229835955-6cfb74fe-1ff0-4549-a67a-80c3398442d0.png" width="23%" height="25%" /> | <img src = "https://user-images.githubusercontent.com/99719661/229837239-21f95f4f-5328-4034-a4e5-751ae113f048.png" 
width="23%" height="25%" /> | <img src = "https://user-images.githubusercontent.com/99719661/229839188-e1cceea9-b560-4e35-81a3-2ca75fbda9d3.png" width="23%" height="25%" /> | <img src = "https://user-images.githubusercontent.com/99719661/229841637-71f75109-efd2-4ca4-b157-a4fc22d3a821.png" width="23%" height="25%" /> 

- **전체 목록 화면**   
  - 좋아요, 리뷰, 나의 라멘 가게 목록으로 들어갈 수 있는 화면입니다. 

<br/>

- **좋아요 목록 화면**
  - 좋아요를 누른 가게와 별점을 볼 수 있습니다.
  - 해당 칸을 누르면 가게 정보 화면으로 넘어갑니다.
  
<br/>

- **리뷰 목록 화면**
  - 리뷰를 마친 가게들을 볼 수 있습니다.
  - 목록에 있는 칸을 누르면 리뷰 화면으로 넘어가서 리뷰 내용을 수정할 수 있습니다. 
  - 편집 버튼을 누르면 리뷰 목록에서 가게를 삭제할 수 있습니다.  
<br/>

- **나의 라멘 가게 목록 화면**
  - 나의 라멘 가게 목록에 추가한 가게들을 볼 수 있습니다. 

<br/>

### 6. 검색창 화면 

<img src = "https://user-images.githubusercontent.com/99719661/229838397-2db731a3-d60a-4636-855f-ffc35b4ba030.png" 
width="25%" height="25%" />

- 현재 위치를 기반으로 주변 가게들을 목록에 있는 칸에 보여줍니다.
- 보여지는 가게들 내에서 검색이 가능합니다.
- cell을 누르면 가게 정보 화면으로 넘어갑니다.
- 검색을 할 때에는 해당되는 지역내의 가게들만 볼 수 있습니다.

<br/>

### 기타 사항

- 지역이름과 위도, 경도는 JSON 형식으로 직접 만들었습니다.
- JSON 파싱을 통해 query로 위도, 경도가 들어가게끔 설정하여 근방의 라멘 가게들을 불러옵니다.
- 별점을 0.5점 단위로 매길 수 있습니다.

<br/>

## 트러블 슈팅

> Windows + Codemagic CI 환경으로 넘어오면서 겪은 빌드 관련 트러블슈팅은 [README_TROUBLESHOOTING.md](./README_TROUBLESHOOTING.md)에 따로 정리했습니다.

문제 : 라멘 이미지들을 데이터 통신을 하여 가져오는 것이 어려웠음

- 가게 이미지를 가져오는 API의 파라미터로 가게이름(`storeName`)이 필요했음.
    - 기존에 가게 리스트를 가져올 때 저장한 `storeNames` 배열을 활용하기로 결정.
    - storeNames 에 대해 for문을 돌려 `getRamenImages`(이미지 데이터를 가져오는 데이터 통신을 하는 함수)의 인자로 사용함.
    - `getRamenImages`의 실행 결과인 이미지 URL들을 `imageUrlList` 배열 에 담아줌.
    - `imageUrlList`를 UIImage 타입으로 바꾸어 imageView에 대입.
    
- 실행 결과`storeNames`이 빈배열이여서 이미지를 가져올 수가 없는 상황이 발생
    - 원인: 이미지를 가져오는 함수를 실행시키는 시점이 문제로 확인.
    가게 정보를 가져오는 API 호출(`getRamenData`)보다 
    이미지 정보를 가져오는 API(`getRamenImages`)가 먼저 호출되고 있었음.
    (`viewDidLoad()`에서 `getRamenImages`를 호출했기 때문)
    - `storeNames`의 배열에 필요로 하는 데이터 갯수만큼 통신이 끝난 후에 `getRamenImages` 함수 실행이 이루어져야 해당 오류를 고칠 수 있다는 것을 알게 되었음.
    - `getRamenData` 함수 안 `storeNames`의 배열에
        
가게 이름이 모두 담은 후에 `getRamenImages` 함수를 실행함으로써 문제를 해결함.

<br/>

## 업데이트 사항(ver 1.1)

1. UI 업데이트

2. 검색 시 발생하는 버그 수정

<br/>

## 업데이트 사항(ver 1.2) — 코드 전수 분석 및 기능 고도화

### 배경 및 목적

한동안 관리하지 않았던 앱을 다시 열어보면서, 실제 동작 방식과 코드 구조를 처음부터 다시 전수 분석했습니다. 그 과정에서 드러난 잠재적 버그와 기술 부채를 먼저 정리해서 고치고, 이어서 "겉보기엔 되는 것 같지만 실제로는 아쉬운" 핵심 기능들을 실사용 가능한 수준으로 보강했습니다.

### 작업 흐름

1. **전체 코드 분석** — 모든 소스 파일을 읽으며 아키텍처(MVC), 데이터 흐름(Kakao API 조회 → `RamenData` 변환 → Realm 저장 → 화면 표시), 화면·모델별 역할을 파악했습니다.
2. **API 키 유효성 점검** — 프로젝트에 하드코딩된 채 git 이력에 그대로 남아있던 Kakao API 키를 발견하고, 실제로 살아있는 키인지 REST 호출로 직접 검증했습니다.
3. **분석 중 발견한 문제 수정**
   - `RegionData.load()`가 빈 문자열 파일명(`fileName = ""`)에 의존해 우연히 동작하고 있던 것을 `"RegionInformation"`으로 명시.
   - `SearchViewCell`에 스토리보드로만 연결돼 있고 코드에서는 쓰이지 않던 `searchResultLabel` 아웃렛을 실제로 사용하도록 수정.
   - Xcode 프로젝트에 등록조차 안 되어 빌드에 포함되지 않던 고아 파일 `ReviewTextAlert.swift` 삭제.
   - Realm `schemaVersion`이 명시돼 있지 않던 것을 `AppDelegate`에서 버전(1)으로 고정해, 이후 스키마 변경 시 안전하게 마이그레이션할 수 있는 기준점 마련.
   - Kakao API 키가 담긴 `RamenInfo.plist`를 git 추적에서 제외하고 `.gitignore`에 등록, `RamenInfo.plist.sample` 템플릿을 대신 추가. 키는 재발급받아 로컬에서만 교체.
4. **핵심 기능 고도화** — 분석 과정에서 스스로 진단한 "당장 손볼 만한 기능적 아쉬움" 4가지를 개선했습니다.

### 이번에 추가/개선한 기능

- **검색 재질의**: 기존엔 최초 로드된 15건 안에서만 가게 이름을 텍스트로 걸러내던 "가짜 검색"이었던 것을, 검색어 입력 시 Kakao API에 직접 재질의(0.4초 디바운스 적용)하고 스크롤을 내리면 다음 페이지까지 이어 받는 무한 스크롤 페이지네이션으로 개선했습니다.
- **정렬 옵션**: 홈/검색 화면 내비게이션 바에 거리순·평점순 정렬 메뉴를 추가했습니다.
- **지도 보기**: 홈/검색/마이리스트(좋아요·나의 라멘 가게) 화면에 지도 아이콘을 추가해 결과를 지도 핀으로 한눈에 확인하고, 핀 콜아웃에서 바로 상세 화면으로 이동할 수 있도록 `MapViewController`를 신규 추가했습니다.
- **GPS 위치 우선 사용**: 기존엔 위치 권한을 허용해도 항상 지역선택(JSON)의 고정 좌표로만 검색했던 것을, 최초 진입 시 GPS 응답을 최대 3초 기다렸다가 우선 사용하고, GPS를 못 받을 때만 지역 기본값으로 대체하도록 변경했습니다. 지역 변경 버튼은 언제든 수동으로 다른 지역을 선택할 수 있는 보조 수단으로 그대로 남겨두었습니다.

### 참고

- 이 업데이트는 Xcode가 없는 환경에서 진행되어, 실제 빌드·시뮬레이터 검증은 별도로 Xcode에서 확인이 필요합니다.
