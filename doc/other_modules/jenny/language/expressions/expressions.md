<a id="expressions"></a>

# 표현식

YarnSpinner의 **표현식**은 [연산자][operators]나 [함수][function] 호출과 결합한 [변수][variables]를
바탕으로 대화의 흐름이나 내용을 동적으로 바꾸는 방법을 제공합니다. 표현식은 여러 곳에서 사용됩니다.

- [줄][line]에 동적인 텍스트를 삽입할 때
- [변수][variable]를 만들거나 갱신할 때
- `<<if>>`나 `<<set>>` 같은 [명령][command]의 일부로
- [마크업][markup] 속성의 값을 계산할 때

표현식은 항상 동기적으로 평가됩니다. 즉, 사용자의 입력을 기다리거나, 시간에 걸쳐 동작을 수행하거나,
다른 스레드에서 계산 집약적인 연산을 수행할 수 없습니다. 이런 기능이 꼭 필요하다면, 계산이 끝날 때까지
기다린 다음 결과를 전역 [변수][variable]에 저장하는 [사용자 정의 명령][user-defined command]을 통해
구현할 수 있으며, 그 변수는 표현식에서 접근할 수 있습니다.


```{toctree}
:hidden:

변수        <variables.md>
연산자      <operators.md>
함수        <functions/functions.md>
```

[command]: ../commands/commands.md
[function]: functions/functions.md
[line]: ../lines.md
[markup]: ../markup.md
[operators]: operators.md
[user-defined command]: ../commands/user_defined_commands.md
[variable]: variables.md
[variables]: variables.md
