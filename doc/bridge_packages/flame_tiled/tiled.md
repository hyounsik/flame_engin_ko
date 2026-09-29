# Tiled

[Tiled]는 레벨과 맵을 디자인하기 위한 훌륭한 도구입니다. [Tiled] 문서에서는 다음과 같이 설명합니다.

> Tiled는 게임 콘텐츠 개발을 돕는 2D 레벨 에디터입니다. 주요
> 기능은 다양한 형태의 타일맵을 편집하는 것이지만, 자유로운 이미지 배치와
> 게임에서 사용하는 추가 정보로 레벨에 주석을 다는 강력한 방법도
> 지원합니다. Tiled는 직관성을 유지하면서도 전반적인 유연성에
> 중점을 둡니다.
>
> 타일맵의 경우 일반적인 직사각형 타일 레이어뿐 아니라
> 투영된 isometric, staggered isometric, staggered hexagonal 레이어도 지원합니다.
> 타일셋은 여러 타일을 담은 하나의 이미지일 수도 있고,
> 개별 이미지들의 모음일 수도 있습니다. 특정 깊이 표현 기법을
> 지원하기 위해 타일과 레이어를 원하는 거리만큼 오프셋할 수 있으며
> 렌더링 순서도 설정할 수 있습니다.


![Tiled Editor](../../images/TiledEditor.jpg)


Flame은 TMX(XML) 파일을 파싱하고 그 안의 타일, 오브젝트 등 모든 것에 접근할 수 있게 해 주는
[dart] 패키지를 묶은 패키지([flame_tiled])를 제공합니다.

[dart] 패키지는 간단한 `Tiled` 클래스를 제공하고, [flame_tiled]는 맵 렌더링을 위한 컴포넌트 래퍼
`TiledComponent`를 제공합니다. 이 컴포넌트는 화면에 타일을 렌더링하며
회전과 뒤집기를 지원합니다.


<a id="tiled-editor"></a>

## Tiled 에디터

[Tiled] 맵 에디터를 다운로드해 게임에 불러올 수 있는 인터랙티브 맵을 만들 수 있습니다.
기본적으로 [Tiled] 맵 에디터는 게임에서 파싱해 사용할 수 있는 TMX 파일을
생성합니다.


[dart]: https://pub.dev/packages/tiled
[flame_tiled]: https://github.com/flame-engine/flame/tree/main/packages/flame_tiled
[Tiled]: https://www.mapeditor.org/
