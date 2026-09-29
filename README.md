# Flame Engine 문서 한국어 번역

[Flame](https://github.com/flame-engine/flame) 공식 문서(https://docs.flame-engine.org)의 비공식 한국어 번역입니다.

## 번역 기준

| 항목 | 내용 |
|---|---|
| Flame 버전 | `1.38.0` (`packages/flame/pubspec.yaml` 기준) |
| 원본 브랜치 / 커밋 | `main` / [`0a09062`](https://github.com/flame-engine/flame/commit/0a090628cfcf3c1aa5b009f2a414370a13bf4cf9) (2026-09-28) |
| 번역 작업일 | 2026-09-29 |

원본 `main` 브랜치 기준이므로 1.38.0 릴리스 이후 아직 배포되지 않은 변경이 일부 포함될 수 있습니다.
기준 커밋 해시는 `UPSTREAM_COMMIT` 파일에도 기록되어 있습니다.

## 로컬에서 빌드하기

```shell
python3 -m venv .venv
.venv/bin/pip install -r doc/_sphinx/requirements.txt
dart pub global activate dartdoc_json   # {dartdoc} 지시문용
PATH="$HOME/.pub-cache/bin:$PATH" .venv/bin/sphinx-build -M html doc doc/_build -c doc/_sphinx
open doc/_build/html/index.html
```

원문의 인터랙티브 예제(`{flutter-app}`)는 Flame 예제 앱 빌드가 필요해서 이 번역본에는 표시되지 않습니다.

## 원문 업데이트 따라가기

1. 원문 저장소를 받아 `git diff <UPSTREAM_COMMIT>..HEAD -- doc CONTRIBUTING.md`로 바뀐 파일을 확인합니다.
2. 바뀐 부분만 [번역 가이드](TRANSLATION_GUIDE.md)에 따라 번역합니다.
   `{dartdoc}` 페이지의 API 설명은 `packages/` 아래 Dart 파일의 `///` 주석에서 만들어지므로,
   원문의 해당 Dart 파일이 바뀌었다면 새로 복사한 뒤 `///` 주석만 번역합니다.
3. `.venv/bin/python tools/check_translation.py <원문>/doc --fix-anchors`로 코드 블록과 앵커를 검사합니다.
4. `UPSTREAM_COMMIT`과 이 README의 번역 기준 표를 갱신합니다.

## 라이선스

원본과 동일한 MIT License (Copyright (c) 2021 Blue Fire)를 따릅니다. `LICENSE` 참고.
번역 내용이 원문과 다를 경우 영어 원문이 우선합니다.
