# `<<wait>>`

**\<\<wait\>\>** 명령은 대화 엔진이 대화를 재개하기 전에 지정한 시간(초 단위) 동안 기다리게 합니다.
초 값은 0일 수 있지만 음수일 수는 없습니다. 이 명령은 숫자 표현식이어야 하는 인자 하나를 받습니다.
예를 들면 다음과 같습니다.
```yarn
// Wait for a quarter of a second
<<wait 0.25>>

// Wait for the amount of time given by the $delay variable
<<wait $delay>>
```
