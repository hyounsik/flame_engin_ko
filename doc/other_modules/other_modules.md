<a id="other-modules"></a>

# 기타 모듈

:::{package} forge2d

이 모듈은 Box2D 물리 엔진의 Dart 바인딩을 제공하며, 모바일과 데스크톱에서는 네이티브로,
웹에서는 WebAssembly로 실행됩니다. 어떤 Dart 프로젝트에서든 사용할 수 있으며, Flame 게임에 추가하려면
브릿지 패키지 `flame_forge2d`를 사용합니다.
:::

:::{package} jenny

이 모듈을 사용하면 게임에 인터랙티브 대화를 추가할 수 있습니다. 모듈 자체는 Yarn 스크립트와
대화 런타임을 처리하며, Flame 게임에 추가하려면 브릿지 패키지 `flame_jenny`를 사용합니다.
:::

:::{package} oxygen

Oxygen은 지원 중단(deprecated)되었고 더 이상 유지보수되지 않으므로 사용을 권장하지 않습니다.
거의 모든 경우에 Flame Component System도 그만큼 효율적입니다.
:::


```{toctree}
:hidden:

forge2d                <forge2d/forge2d.md>
forge2d 마이그레이션   <forge2d/migration.md>
jenny                  <jenny/jenny.md>
oxygen                 <oxygen/oxygen.md>
```
