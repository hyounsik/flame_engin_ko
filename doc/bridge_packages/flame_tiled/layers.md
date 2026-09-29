<a id="layers"></a>

# 레이어

가장 간단하게는 다음을 호출해 Tilemap에서 레이어를 가져올 수 있습니다.

```dart
getLayer<ObjectGroup>("myObjectGroupLayer");
getLayer<ImageLayer>("myImageLayer");
getLayer<TileLayer>("myTileLayer");
getLayer<Group>("myGroupLayer");
```

이 메서드들은 요청한 타입의 레이어를 반환하거나, 레이어가 없으면 null을 반환합니다.


<a id="layer-properties"></a>

## 레이어 속성

다음 Tiled 속성을 지원합니다.

- [x] Visible(표시 여부)
- [x] Opacity(불투명도)
- [ ] Tint color(틴트 색상)
- [x] Horizontal offset(가로 오프셋)
- [x] Vertical offset(세로 오프셋)
- [x] Parallax factor(패럴랙스 계수)
- [x] Custom properties(커스텀 속성)


<a id="tiles-properties"></a>

## 타일 속성

- 타일은 `tile.properties`로 접근할 수 있는 커스텀 속성을 가질 수 있습니다.
- 타일은 `tile.type`으로 접근할 수 있는 커스텀 `type`(Tiled v1.9부터는 `class`)을 가질 수 있습니다.


<a id="other-features"></a>

## 기타 기능

그 밖의 고급 기능은 아직 지원하지 않지만, TMX의 오브젝트와 기타 기능을 쉽게 읽어
커스텀 동작(예: 트리거 영역과 이동 가능 영역, 커스텀 애니메이션 오브젝트)을
추가할 수 있습니다.


<a id="full-example"></a>

## 전체 예제

동작하는 예제는
[여기](https://github.com/flame-engine/flame/tree/main/packages/flame_tiled/example)에서 확인할 수 있습니다.
