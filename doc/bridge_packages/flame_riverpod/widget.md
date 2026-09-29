<a id="widget"></a>

# 위젯


## RiverpodAwareGameWidget

`RiverpodAwareGameWidget`은 `RiverpodAwareGameWidgetState` 타입의 `State` 객체를 가진
GameWidget입니다.

필수 인자인 `GlobalKey`는 `RiverpodComponentMixin`을 사용하는 `Component`가
`RiverpodAwareGameWidgetState`를 통해 `Provider`에 접근할 수 있도록 하는 데 사용됩니다.


## RiverpodAwareGameWidgetState

`RiverpodAwareGameWidgetState`는 `flutter_riverpod`의 `ConsumerStatefulElement`와
`flame`의 `GameWidgetState`가 담당하는 역할을 수행합니다.
