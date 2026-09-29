# 번역 가이드

Flame 공식 문서(MIT License)를 한국어로 옮길 때 지키는 규칙입니다.

## 원칙

- 문체는 `~합니다`체로 통일합니다. 기술 문서답게 간결하게 씁니다.
- 직역보다 자연스러운 한국어를 우선하되, 의미를 더하거나 빼지 않습니다.
- 원문의 문단/제목/목록 구조를 그대로 유지합니다. 문장 단위로 줄을 합치거나 나누지 않습니다.

## 번역하지 않는 것

- 코드 블록(```` ```dart ```` 등)의 내용. 단, 코드 안의 **주석**은 번역합니다.
- 인라인 코드(`` `Component` ``), 클래스/메서드/파라미터 이름, 파일 경로, 패키지 이름.
- MyST/Sphinx 지시문 이름과 옵션: ```` ```{toctree} ````, ```` ```{flutter-app} ````, ```` ```{dartdoc} ````, `:sources:`, `:page:`, `:show:`, `:file:`, `:symbol:`, `:package:`, `:hidden:`, `:maxdepth:` 등. 옵션 값도 그대로 둡니다.
- `{toctree}` 안의 문서 경로 목록 (`Title <path.md>` 형식이면 **Title만** 번역).
- 링크 URL, 앵커(`#section-id`), 이미지 경로, 참조 라벨(`[label]: url` 의 label과 url).
- HTML 태그와 속성.

## 앵커 보존 (중요)

다른 문서가 `file.md#some-heading` 형태로 제목 앵커를 참조합니다. 제목을 번역하면 자동 생성 앵커가 바뀌어 링크가 깨지므로,
**H1~H4 제목을 번역할 때는 원래 영어 제목에서 만들어지던 앵커를 명시적 타깃으로 제목 바로 위에 붙입니다.**

```markdown
(sizeeffectby)=
### SizeEffectBy
```

- 앵커 규칙: 원문 제목을 소문자로, 공백은 `-`로, 영문자/숫자/`-`/`_` 외 문자는 제거 (예: `Game Loop` → `game-loop`, `Basic usage` → `basic-usage`).
- 제목이 코드/고유명사라 번역하지 않는 경우(예: `### SizeEffectBy`)에는 타깃을 붙이지 않아도 됩니다.
- 이미 `(label)=` 타깃이 있는 제목은 그대로 둡니다.
- 문서 안의 링크 `[text](other.md#anchor)` 는 텍스트만 번역하고 `#anchor`는 원문 그대로 둡니다.

## 용어집

원어 유지가 기본입니다. 한국 개발자들이 영어로 쓰는 용어는 번역하지 않습니다.

| 원문 | 번역 |
|---|---|
| component | 컴포넌트 |
| game loop | 게임 루프 |
| sprite / sprite sheet | 스프라이트 / 스프라이트 시트 |
| effect | 이펙트 |
| camera / viewport / viewfinder | 카메라 / 뷰포트 / 뷰파인더 |
| world | 월드 |
| collision detection | 충돌 감지 |
| hitbox | 히트박스 |
| mixin | 믹스인 |
| widget | 위젯 |
| overlay | 오버레이 |
| render / rendering | 렌더링하다 / 렌더링 |
| canvas | 캔버스 |
| anchor | 앵커 |
| lifecycle | 생명주기 |
| event / callback | 이벤트 / 콜백 |
| tap / drag / gesture | 탭 / 드래그 / 제스처 |
| keyboard | 키보드 |
| particle | 파티클 |
| shader | 셰이더 |
| tile / tileset | 타일 / 타일셋 |
| bridge package | 브릿지 패키지 |
| tutorial | 튜토리얼 |
| asset | 에셋 |
| parent / child / children | 부모 / 자식 / 자식들 |
| property | 속성 |
| method | 메서드 |
| constructor | 생성자 |
| instance | 인스턴스 |
| override | 오버라이드 |
| deprecated | 지원 중단(deprecated) |
| note / warning / tip (admonition 제목) | 참고 / 경고 / 팁 |
| priority | 우선순위 |
| delta time (dt) | 델타 타임(dt) |
| frame | 프레임 |
| position / size / scale / angle | 위치 / 크기 / 스케일 / 각도 |
| vector | 벡터 |

고유명사(Flame, Flutter, Dart, Forge2D, Tiled, Rive, Jenny, Yarn Spinner, Bonfire, Blue Fire 등)는 그대로 둡니다.
