# `<<character>>`

**\<\<character\>\>** 명령은 주어진 이름과, 스크립트에서 사용할 수 있는 하나 이상의 별칭(alias)을
가진 캐릭터를 선언합니다.

이 명령에는 여러 목적이 있습니다.

- 스크립트에서 캐릭터 이름의 철자를 실수로 틀리는 것을 막아 줍니다.
- 캐릭터가 ID일 필요가 없는 *전체 이름*을 가질 수 있게 합니다.
- 같은 캐릭터에 대해 여러 별칭을 선언하여 서로 다른 노드에서 사용할 수 있게 합니다(별칭은 전체
  이름과 다른 언어일 수도 있습니다).
- 각 캐릭터에 추가 데이터를 연결할 수 있으며, 이 데이터는 런타임에 사용할 수 있습니다.

이 명령의 형식은 다음과 같습니다.
```yarn
<<character "FULL NAME" alias1 alias2...>>
```

여기서 *전체 이름(FULL NAME)*은 선택 사항입니다. 지정하면 그것이 캐릭터의 *진짜* 이름으로 간주됩니다.
하지만 이름을 생략하면 첫 번째 별칭이 캐릭터의 진짜 이름으로 간주됩니다.
각 *별칭*은 유효한 ID여야 하며, 별칭은 최소 하나 이상 제공해야 합니다. 예를 들면 다음과 같습니다.
```yarn
// A well-mannered seven-year-old girl, who nevertheless always gets into
// all kinds of zany adventures.
<<character Alice>>

// A magical cat known for his ability to grin majestically, and partially
// vanish. He is mad (by his own admission).
<<character "Cheshire Cat" Cat Cheshire>>

// A foul-tempered Queen, who is also a playing card. Described as
// "a blind fury", her favorite saying is "Off with their heads!".
// Not to be confused with Red Queen.
<<character "Queen of Hearts" Queen QoH QH>>
```

캐릭터를 선언하고 나면 스크립트에서 그 별칭 중 무엇이든 사용할 수 있으며, 모두 같은 `Character`
객체를 가리킵니다. 반면 캐릭터를 먼저 선언하지 않고 사용하는 것은 허용되지 않습니다(`YarnProject`에서
이를 허용하는 특별한 플래그를 설정한 경우는 예외입니다).
```yarn
title: Alice_and_the_Cat
---
Alice: But I don't want to go among mad people.
Cat:   Oh, you can't help that, we're all mad here. I'm mad. You're mad.
Alice: How do you know I'm mad?
Cat:   You must be, or you wouldn't have come here.
Alice: And how do you know that you're mad?
Cat:   To begin with, a dog's not mad. You grant that?
Alice: I suppose so.
Cat:   Well then, you see a dog growls when it's angry, and wags its tail \
       when it's pleased.
Cat:   Now, [i]I[/i] growl when I'm pleased, and wag my tail when I'm angry. \
       Therefore, I'm mad.
Alice: [i]I[/i] call it purring, not growling.
Cat:   Call it what you like.
===
```
