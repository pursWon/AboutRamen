# 개발 트러블슈팅: Windows + Codemagic으로 iOS 앱 빌드하기

이 앱은 원래 맥에서 만들었다. 그런데 이후로는 윈도우 환경에서 작업하게 되면서, 로컬에서 Xcode를 직접 열어서 빌드해볼 방법이 없어졌다. 그래서 선택한 게 Codemagic이었다 — 클라우드에 맥 인스턴스를 띄워서 빌드하고, 결과 화면을 스크린샷으로 받아보는 방식이다. 말은 간단한데, 실제로 파이프라인이 안정적으로 돌아가기까지 삽질을 꽤 했다. 여기에 그 과정을 순서대로 남겨둔다.

## 1. 시뮬레이터를 못 찾는다

처음 `codemagic.yaml`을 작성할 때는 별생각 없이 destination을 이렇게 지정했다.

```yaml
-destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5'
```

로컬에서 쓰던 시뮬레이터 이름을 그대로 옮겨 적은 거였다. 그런데 빌드가 돌자마자 "Unable to find a device matching the provided destination specifier" 에러가 떴다. 처음엔 오타인가 싶어서 이름 철자를 다시 확인했는데 멀쩡했다.

곰곰이 생각해보니 당연한 거였다. Codemagic의 빌드 서버는 내가 로컬에서 쓰던 맥이 아니다. `xcode: latest`로 설정해뒀으니, 그 시점에 Codemagic이 제공하는 최신 Xcode에 실제로 어떤 시뮬레이터가 깔려 있는지는 내가 지정한 이름/OS 조합과 다를 수 있다는 걸 놓치고 있었다.

그래서 빌드 스크립트에 확인 단계를 하나 끼워 넣었다.

```yaml
- name: 사용 가능한 시뮬레이터 확인
  script: |
    xcrun simctl list devices available
```

이 로그를 열어보니 내가 요청한 조합은 없고, 대신 다른 UUID를 가진 시뮬레이터들이 나열되어 있었다. 이름이나 OS 버전으로 지정하는 방식은 Codemagic 이미지가 바뀔 때마다 또 깨질 수 있겠다 싶어서, 아예 로그에서 확인한 UUID를 직접 박아 넣는 쪽으로 바꿨다.

```yaml
-destination 'id=1114811B-9965-4FCA-A185-B1000429EC83'
```

이렇게 하니 일단 destination을 못 찾는 문제는 사라졌다. 다만 이 UUID 고정 방식은 나중에 Xcode 버전 자체를 낮추면서 다시 이름 기반으로 돌아가게 되는데, 그 얘기는 아래 2번에 이어진다.

## 2. Kingfisher가 컴파일이 안 된다

destination 문제를 넘기고 나니 이번엔 빌드가 exit code 65로 죽었다. 그런데 로그를 봐도 정확히 뭐가 문제인지 잘 안 보였다. 경고 메시지들 때문인지 실제 에러 라인이 수백 줄 사이에 파묻혀 있었다.

로그 전체를 눈으로 훑는 대신, grep으로 실제 에러만 걸러내는 쪽으로 스크립트를 바꿨다.

```yaml
xcodebuild build ... \
  2>&1 | grep -E "error:|cannot find|no such module" || true
```

그렇게 좁혀보니 진짜 원인이 나왔다.

```
KFImageRenderer.swift: error: initializer for conditional binding must have
Optional type, not 'AnyView'
```

Kingfisher 내부 코드에서 나는 에러였다. 처음엔 "내 코드가 아닌데 왜 나한테 에러가 나나" 싶었는데, 원인은 결국 컴파일러 버전이었다. `xcode: latest`로 두고 있었으니 최신 Swift 6 컴파일러가 붙는데, 당시 프로젝트가 물고 있던 Kingfisher 7.5.0은 그 정도로 엄격해진 옵셔널·타입 추론 규칙까지는 대응이 안 돼 있었던 것 같다.

첫 시도는 컴파일러 쪽을 억지로 누그러뜨리는 거였다.

```yaml
SWIFT_VERSION=5 \
SWIFT_STRICT_CONCURRENCY=minimal \
OTHER_SWIFT_FLAGS="-warnings-as-errors false"
```

플래그로 Swift 5 모드를 강제하고 동시성 체크를 최소로 낮춰봤는데, 이건 근본적인 해결이 아니었다. 여전히 최신 툴체인이 소스를 파싱하는 단계에서부터 걸리고 있었고, 빌드 플래그 몇 개로 우회할 수 있는 범위를 넘어서 있었다.

결국 방향을 바꿔서 Xcode 자체를 16.2로 내렸다. `SWIFT_VERSION=5`를 억지로 붙이는 것보다, 애초에 Swift 5를 기본으로 쓰는 Xcode 버전을 그대로 쓰는 게 더 확실하다고 판단했다. 프로젝트의 빌드 세팅도 원래 `SWIFT_VERSION = 5.0`으로 잡혀 있었으니, 최신 Xcode에 억지로 맞추는 것보다 프로젝트가 원래 짜여진 버전대의 Xcode를 쓰는 쪽이 자연스러운 선택이었다.

```yaml
environment:
  xcode: 16.2
```

Xcode를 16.2로 내리고 나니, 이번엔 그 이미지에 iPhone 17 / OS 26.5 시뮬레이터가 없었다. 16.2가 기본으로 들고 있는 건 iPhone 16 / OS 18.2였다. 그래서 destination도 다시 이름 기반으로 되돌렸다.

```yaml
-destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2'
```

돌이켜보면 1번에서 UUID로 고정했던 건 "이미지가 바뀌어도 안 흔들리게" 하려던 임시방편이었는데, 결국 Xcode 버전 자체를 못 박고 나니 그 안에서는 이름 기반 지정도 충분히 안정적이었다. 문제의 본질은 destination을 어떻게 지정하느냐가 아니라, 어떤 Xcode를 쓸지가 애초에 고정돼 있지 않았다는 쪽에 더 가까웠던 셈이다.

## 3. RamenInfo.plist를 못 찾는다

Kingfisher 문제까지 넘기고 나니 이번엔 다른 에러가 났다.

```
Build input file cannot be found: '.../AboutRamen/RamenInfo.plist'
```

처음엔 빌드 스크립트가 경로를 잘못 참조하나 싶어서 프로젝트 설정을 다시 봤는데, 곧 이유가 떠올랐다. 이 파일에는 Kakao API 키가 실제 값으로 들어가 있다. 예전에 이 키가 그대로 git에 커밋돼 있던 걸 발견하고 `.gitignore`에 올려서 추적을 끊어둔 적이 있었는데, 그러니 Codemagic이 저장소를 클론해오는 시점에는 이 파일이 아예 없는 게 맞는 동작이었다. 버그가 아니라, 예전에 넣어둔 보안 조치가 정상적으로 작동한 결과였던 것이다.

문제는 "그럼 CI에서는 이 값을 뭘로 채우지"였다. 실제 키를 CI 환경변수로 주입하는 방법도 있었지만, 이 빌드는 어차피 실제 API 응답까지는 필요 없는 단순 컴파일 + 스크린샷 확인용이었다. 그래서 실제 키 대신 더미 값이 들어간 예시 파일을 저장소에 커밋해두고, 빌드 스크립트 맨 앞에서 그걸 실제 파일 이름으로 복사해주는 단계를 추가했다.

```yaml
- name: 더미 API 키 파일 준비
  script: |
    cp AboutRamen/RamenInfo.plist.example AboutRamen/RamenInfo.plist
```

이렇게 하면 실제 키는 여전히 저장소 밖에 남아있으면서, 빌드는 "파일이 존재하기만 하면 되는" 조건을 채울 수 있었다. 진짜 API 응답이 필요한 배포용 빌드였다면 이 방식만으로는 부족했겠지만, 지금 단계에서는 컴파일이 되고 화면이 뜨는지만 확인하면 됐기 때문에 이 정도로 충분하다고 판단했다.

## 배운 것

세 문제 다 원인은 제각각이었지만 돌아보면 공통점이 있었다. 로컬에서 잘 되던 걸 그대로 클라우드에 옮기면 반드시 어딘가 어긋난다는 것, 그리고 그 어긋남은 로그를 얼마나 좁혀서 보느냐에 따라 찾아내는 속도가 확 달라진다는 것. 특히 두 번째 문제에서 grep으로 에러 라인만 걸러본 게 제일 크게 도움이 됐다. 경고 수백 줄 사이에서 진짜 원인 한 줄을 찾아내는 것과, 처음부터 좁혀서 보는 것의 차이가 컸다. 다음에 비슷한 CI 환경을 새로 꾸릴 일이 있으면, 처음부터 로그를 최소화해서 보는 습관을 들여야겠다.
