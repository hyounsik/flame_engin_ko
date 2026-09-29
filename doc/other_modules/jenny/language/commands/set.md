# `<<set>>`

**\<\<set\>\>** 명령은 기존 변수의 값을 갱신하는 데 사용합니다. 변수는 `<<set>>`에서 사용하기 전에
[\<\<declare\>\>][declare]나 [\<\<local\>\>][local]로 선언되어 있어야 합니다.

`<<set>>` 명령은 다음과 같이 일반 할당이나 수정 할당을 할 수 있습니다.
```yarn
// Regular assignment
<<set $VARIABLE = EXPRESSION>>
<<set $VARIABLE to EXPRESSION>>

// Modifying assignments
<<set $VARIABLE += EXPRESSION>>
<<set $VARIABLE -= EXPRESSION>>
<<set $VARIABLE *= EXPRESSION>>
<<set $VARIABLE /= EXPRESSION>>
<<set $VARIABLE %= EXPRESSION>>

// These modifying assignments are equivalent to the following:
<<set $VARIABLE = $VARIABLE + EXPRESSION>>
<<set $VARIABLE = $VARIABLE - EXPRESSION>>
<<set $VARIABLE = $VARIABLE * EXPRESSION>>
<<set $VARIABLE = $VARIABLE / EXPRESSION>>
<<set $VARIABLE = $VARIABLE % EXPRESSION>>
```

모든 경우에 `EXPRESSION`은 `$VARIABLE`과 같은 타입이어야 합니다. 그렇지 않으면 컴파일 타임 오류가
발생합니다.


<a id="examples"></a>

## 예제
```yarn
<<declare $favorite_color as String>>

title: ColorQuiz
---
What is your favorite color?
-> White
   <<set $favorite_color to "White">>
-> Red
   <<set $favorite_color to "Red">>
-> Yellow
   <<set $favorite_color = "Yellow">>
-> Blue
   Oh, Nice! Which shade of blue?
   -> Azure
   -> Cerulean
   -> Lapis Lazuli
   Umm, I don't know how to spell that. I'll just put you down as "blue".
   <<set $favorite_color = "Blue">>
-> Black
   <<set $favorite_color = "Black">>
   That's mine too!
   <<set $affinity += 3>>
-> Prefer not to tell
   Aww... Maybe if I ask again really nicely?
   <<jump ColorQuiz>>
===
```


[declare]: declare.md
[local]: local.md
