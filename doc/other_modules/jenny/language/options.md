<a id="options"></a>

# 옵션

**옵션**은 플레이어에게 선택지 메뉴를 표시하는 특별한 줄이며, 플레이어는 계속 진행하려면 그중
하나를 선택해야 합니다. 옵션은 줄의 시작 부분에 화살표 `->`로 표시합니다.
```yarn
title: Adventure
---
You arrive at the edge of the forest. The road dives in, but there is another \
one going around the edge.
-> Go straight ahead, on the beaten path (x)
-> Take the road along the forest's edge
-> Turn back
===
```

옵션 뒤에는 보통 들여쓰기된 문장 목록(역시 줄, 옵션, 명령일 수 있음)이 옵니다. 이 문장들은
플레이어가 해당 옵션을 선택했을 때 대화가 어떻게 진행될지를 나타냅니다. 선택된 옵션에 해당하는
블록의 실행이 끝나면, 대화는 옵션 세트 다음부터 다시 이어집니다.

화살표 표시를 제외하면 옵션은 [줄][line]과 같은 문법을 따릅니다. 따라서 캐릭터 이름, 본문 텍스트,
보간 표현식, 마크업, 해시태그를 가질 수 있습니다. 옵션이 가질 수 있는 추가 기능 하나는
**조건문(conditional)**입니다. 조건문은 옵션의 텍스트 뒤(해시태그 앞)에 오는 짧은 형태의 `<<if>>`
명령입니다.
```yarn
title: Bridge
---
Guard: 50 coins and you can cross the bridge.
-> Alright, take the money  <<if $gold >= 50>>
   <<take gold 50>>
   <<grant bridge_pass>>
-> I have so much money, here, take a 100  <<if $gold >= 10000>>
   <<take gold 100>>
   <<grant bridge_pass>>
   Guard: Wow, so generous!
   Guard: But I wouldn't recommend going around telling everyone that you \
          have "so much money"
-> That's too expensive!
   Guard: Is it? My condolences
-> How about I [s]kick your butt[/s] instead?
   <<if $power < 1000>>
      <<fight>>
   <<else>>
      You make a very reasonable point, sir, my apologies.
      <<grant bridge_pass>>
   <<endif>>
===
```

조건문이 `true`로 평가되면 옵션은 평소처럼 게임에 전달됩니다. 조건문이 false로 평가되더라도
옵션은 여전히 전달되지만 `unavailable`로 표시됩니다. 이런 옵션을 회색으로 표시할지, 줄을 그어
표시할지, 아예 표시하지 않을지는 게임이 결정하지만, 어떤 경우든 이런 옵션은 선택할 수 없습니다.

눈치챘겠지만 옵션은 항상 그룹으로 나옵니다. 결국 플레이어는 여러 가능한 선택지 중에서 골라야
하기 때문입니다. 따라서 대화에서 서로 인접한 옵션들의 연속은 항상 하나의 묶음으로 프론트엔드에
전달됩니다. 이를 **선택 세트(choice set)**라고 합니다.

[line]: lines.md
