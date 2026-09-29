# `<<visit>>`

**\<\<visit\>\>** 명령은 현재 노드를 일시적으로 보류하고 대상 노드를 실행한 다음, 그 노드가 끝나면
이전 노드의 실행을 재개합니다. 많은 프로그래밍 언어의 함수 호출과 비슷합니다.

`<<visit>>` 명령은 큰 대화를 여러 개의 작은 노드로 나누거나, 여러 노드에서 공통 대화 줄을
재사용할 때 유용합니다. 예를 들면 다음과 같습니다.
```yarn
title: RoamingTrader1
---
<<if $roaming_trader_introduced>>
  Hello again, {$player}!
<<else>>
  <<visit RoamingTraderIntro>>
<<endif>>

-> What do you think about the Calamity?  <<if $calamity_started>>
   <<visit RoamingTrader_Calamity>>
-> Have you seen a weird-looking girl running by? <<if $quest_little_girl>>
   <<visit RoamingTrader_LittleGirl>>
-> What do you have for trade?
   <<OpenTrade>>

Pleasure doing business with you! #auto
===
```

이 명령의 인자는 점프할 노드의 id입니다. 일반 노드 ID로 지정하거나, 중괄호 안의 표현식으로 지정할 수
있습니다.
```yarn
<<visit {"RewardChoice_" + string($choice)}>>
```

표현식이 런타임에 알 수 없는 이름으로 평가되면 `NameError` 예외가 발생합니다.
