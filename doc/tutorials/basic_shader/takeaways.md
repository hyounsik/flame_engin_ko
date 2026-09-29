<a id="takeaways"></a>

# 정리


<a id="conclusion"></a>

## 결론

Flame에서 셰이더를 사용할 때는 세 개의 계층이 관여합니다.

- **컴포넌트 계층** (`SpriteComponent`와 `PostProcessComponent`): 셰이더를 Flame 컴포넌트에
  연결하고, 게임 로직을 담으며, 사용자 입력을 처리합니다.
- **포스트 프로세스 계층** (`PostProcess`): 컴포넌트와 셰이더를 이어 주고, 런타임 설정을 관리하며,
  매 프레임 uniform을 업데이트합니다.
- **GLSL 셰이더** (`.frag` 파일): 최종 픽셀 색상을 결정하는 GPU 프로그램입니다.


<a id="closure"></a>

## 마치며

이 튜토리얼이 Flame에서 셰이더를 사용하는 기본을 이해하는 데 도움이 되었기를 바랍니다. 필요에 맞게
코드를 자유롭게 수정해 보세요. 즐거운 코딩 되세요!

오류를 발견하거나 제안할 내용이 있다면 GitHub이나 Discord를 통해 알려 주세요.
