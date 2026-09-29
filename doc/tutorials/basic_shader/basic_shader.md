<a id="basic-shader-tutorial"></a>

# 기본 셰이더 튜토리얼

이 튜토리얼에서는 Dart/Flutter와 Flame 엔진을 사용해 `PostProcess`와 `PostProcessComponent`로
`SpriteComponent`에 기본 셰이더를 만들고 적용하는 방법을 간단히 알아봅니다.

이 튜토리얼은 동작하는 Flame 프로젝트가 이미 설정되어 있다고 가정합니다. 그렇지 않다면 먼저
[](bare_flame_game.md) 튜토리얼을 따라 하세요.

튜토리얼은 4단계로 구성됩니다. 투명한 배경 레이어를 가진 스프라이트를 위한 간단한 외곽선(outline)
셰이더를 만들어 봅니다.

```{note}
이 튜토리얼은 `.png` 파일처럼 배경이 투명한
이미지에서 동작하도록 만들어졌습니다.
```

*Kornél (Hoodead) Lapu 작성.*


```{toctree}
:hidden:

1. 스프라이트 컴포넌트         <step1.md>
2. 외곽선 포스트 프로세스     <step2.md>
3. 셰이더                   <step3.md>
4. 사용자 입력               <step4.md>
5. 정리                <takeaways.md>
```
