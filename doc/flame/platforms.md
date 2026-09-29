<a id="supported-platforms"></a>

# 지원 플랫폼

Flame의 가장 큰 장점 중 하나는 Flutter의 크로스 플랫폼 지원 범위를 그대로 물려받는다는 것입니다.
하나의 코드베이스로 휴대폰, 데스크톱, 웹용 게임을 만들 수 있습니다. 이 섹션에서는 플랫폼 지원에 관한
세부 사항과 완성한 게임을 널리 쓰이는 호스팅 서비스에 배포하는 방법을 설명합니다.

Flame은 Flutter 위에서 동작하므로, 지원 플랫폼은 Flutter가 지원하는 플랫폼에 따라 달라집니다.

현재 Flame은 웹, 모바일(Android와 iOS), 데스크톱(Windows, macOS, Linux)을 지원합니다.


<a id="flutter-channels"></a>

## Flutter 채널

Flame은 stable 채널을 기준으로 지원합니다. dev, beta, master 채널에서도 동작할 수 있지만
공식적으로 지원하지는 않습니다. 따라서 stable 채널 외에서 발생하는 이슈는 우선순위가 높지 않습니다.


<a id="deploy-your-game-to-github-pages"></a>

## GitHub Pages에 게임 배포하기

게임을 온라인에 배포하는 쉬운 방법 중 하나는 [GitHub Pages](https://pages.github.com/)를 사용하는
것입니다. GitHub Pages는 저장소에서 웹 콘텐츠를 손쉽게 호스팅할 수 있게 해 주는 GitHub의 멋진
기능입니다.

여기서는 GitHub Pages로 게임을 호스팅하는 가장 쉬운 방법을 설명합니다.

먼저 배포된 파일이 저장될 브랜치를 만듭니다:

```shell
git checkout -b gh-pages
```

이 브랜치는 `main`이나 다른 어느 곳에서 만들어도 크게 상관없습니다. 브랜치를 push한 뒤 `main`
브랜치로 돌아갑니다.

이제 저장소에 [flutter-gh-pages](https://github.com/bluefireteam/flutter-gh-pages) 액션을 추가해야
합니다. `.github/workflows` 폴더 아래에 `gh-pages.yaml` 파일을 만들면 됩니다.

```yaml
name: Gh-Pages

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - uses: bluefireteam/flutter-gh-pages@v8
        with:
          baseHref: /NAME_OF_YOUR_REPOSITORY/
          webRenderer: canvaskit
```

`NAME_OF_YOUR_REPOSITORY`를 여러분의 GitHub 저장소 이름으로 꼭 바꾸세요.

이제 `main` 브랜치에 무언가를 push할 때마다 액션이 실행되어 배포된 게임이 업데이트됩니다.

게임은 다음과 같은 URL에서 접속할 수 있습니다:
`https://YOUR_GITHUB_USERNAME.github.io/NAME_OF_YOUR_REPOSITORY/`


<a id="deploy-your-game-to-itchio"></a>

## itch.io에 게임 배포하기

1. IDE에서 또는 `flutter build web`을 실행하여 웹 빌드를 만듭니다
(`Missing index.html` 오류가 나면 `flutter create . --platforms=web`을 실행하세요)
2. `index.html`에서 `<base href="/">`라고 적힌 줄을 삭제합니다
3. `build/web` 폴더를 zip으로 압축해 itch.io에 업로드합니다

**프로젝트 루트의 `web` 디렉터리가 아니라 `build/web` 디렉터리여야 한다는 점을 기억하세요!**

게임 잼에 게임을 제출하는 경우, 게임을 공개로 설정하고 게임 잼 페이지에서도 제출하는 것을 잊지
마세요(많은 사람이 이 부분에서 헷갈립니다).

자세한 안내는 [itch.io](https://itch.io/docs/creators/html5#getting-started/zip-file)에서 확인할 수
있습니다.


<a id="deploy-your-game-to-cloudflare-pages"></a>

## Cloudflare Pages에 게임 배포하기

```{note}
Cloudflare Pages 자동 배포는 GitHub과 GitLab 저장소에서만 사용할 수 있습니다.
```

[Cloudflare pages](https://pages.cloudflare.com/)도 Flame 게임을 온라인에 호스팅하기 좋은 선택지입니다.

자동 배포 설정은 아주 간단해서 몇 단계만으로 완료할 수 있습니다.

먼저 Cloudflare 계정을 만들고, 로그인한 뒤 오른쪽 위의 `+ Add` 버튼을 사용해 페이지 프로젝트를
만듭니다.

![Cloudflare add 메뉴 스크린샷](../images/add_button.png)

다음으로 안내에 따라 저장소를 연결합니다. GitHub과 GitLab 중에서 선택할 수 있습니다.

그러면 프로젝트 이름과 프로덕션 브랜치를 설정하는 화면이 나타납니다. 프로젝트 이름은 저장소 이름으로,
프로덕션 브랜치는 `main`으로 미리 채워져 있을 것입니다.

아래로 스크롤하면 다음과 같은 빌드 설정 패널이 보입니다:

![Cloudflare 빌드 설정 스크린샷](../images/build_form.png)

Flutter는 기본으로 지원되지 않으므로 `Framework preset`은 `None`으로 둡니다.

그런 다음 `Build command` 필드에 다음 명령을 입력합니다:

```shell
if cd flutter; then git pull && cd ..;else
git clone https://github.com/flutter/flutter.git; fi &&
../flutter/bin/flutter doctor && ../flutter/bin/flutter clean &&
../flutter/bin/flutter build web --release
```

한 줄로 입력해야 하지만, 아래에는 읽기 쉽도록 여러 줄로 나누어 표시했습니다:

```shell
if cd flutter; then
  git pull && cd ..
else
  git clone https://github.com/flutter/flutter.git
fi
../flutter/bin/flutter doctor
../flutter/bin/flutter clean
../flutter/bin/flutter build web --release
```

위 명령을 필드에 직접 입력하는 대신 저장소 루트에 bash 스크립트로 만들어 사용하는 편을 선호하는
사람도 있으니, 원하는 방식을 선택하세요.

Build output directory는 `build/web`으로 설정합니다.

필요하다면 고급 옵션을 사용해 환경 변수를 설정합니다.

마지막으로 `Save and Deploy` 버튼을 클릭하면 배포가 시작되고, 이것으로 끝입니다. 이제 저장소에
push할 때마다 게임을 Cloudflare Pages에 배포하는 자동화가 준비되었습니다.


<a id="web-support"></a>

### 웹 지원

웹에서 Flame을 사용할 때는 일부 메서드가 동작하지 않을 수 있습니다. 예를 들어
`Flame.device.setOrientation`과 `Flame.device.fullScreen`은 웹에서 동작하지 않습니다. 호출할 수는
있지만 아무 일도 일어나지 않습니다.

또 다른 예로, `flame_audio` 패키지를 사용한 오디오 사전 캐싱도 Audioplayers가 웹에서 이를 지원하지
않기 때문에 동작하지 않습니다. 이 문제는 `http` 패키지로 오디오 파일에 GET 요청을 보내 우회할 수
있습니다. 그러면 브라우저가 파일을 캐시하여 모바일에서와 같은 효과를 얻을 수 있습니다.

웹에서 `ui.Image` 인스턴스를 만들고 싶다면 Flame의 `Flame.images.decodeImageFromPixels` 메서드를
사용할 수 있습니다. 이 메서드는 `ui` 라이브러리의 `decodeImageFromPixels`를 감싸면서 웹 플랫폼
지원을 추가한 것입니다. `runAsWeb` 인자가 `true`로 설정되면(기본값은 `kIsWeb`) 내부 이미지 메서드를
사용해 이미지를 디코딩합니다. `runAsWeb`이 `false`이면 `decodeImageFromPixels`를 사용하며, 이는
현재 웹에서 지원되지 않습니다.
