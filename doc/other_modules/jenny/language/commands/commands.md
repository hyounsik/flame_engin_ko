<a id="commands"></a>

# 명령

**명령**은 이중 꺾쇠괄호로 감싼 특별한 명령어입니다: `<<stop>>`. 명령에는 *내장* 명령과
*사용자 정의* 명령이 있습니다.

**내장** 명령은 YarnSpinner 런타임 자체가 지원하는 명령입니다. 일반적으로 대화의 실행을 바꾸거나
그와 비슷한 대화 관련 기능을 수행합니다. 이런 명령의 전체 목록은 아래에 있습니다.

**사용자 정의** 명령은 여러분이 직접 만들어 yarn 스크립트 안에서 사용하는 명령입니다. 이런 명령에
대한 자세한 설명은 [사용자 정의 명령][user-defined commands] 문서를 참고하세요.


<a id="built-in-commands"></a>

## 내장 명령


<a id="variables"></a>

### 변수

**[\<\<character\>\>](character.md)**
: 캐릭터(인물)를 선언합니다.

**[\<\<declare\>\>](declare.md)**
: 전역 변수를 선언합니다.

**[\<\<local\>\>](local.md)**
: 지역 변수를 선언합니다.

**[\<\<set\>\>](set.md)**
: 변수(지역 또는 전역)의 값을 갱신합니다.


<a id="control-flow"></a>

### 제어 흐름

**[\<\<if\>\>](if.md)**
: 특정 문장들을 조건부로 실행합니다. 대부분의 프로그래밍 언어의 **if** 키워드에 해당합니다.

**[\<\<jump\>\>](jump.md)**
: 실행을 다른 노드로 전환합니다.

**[\<\<stop\>\>](stop.md)**
: 현재 노드의 실행을 중지합니다.

**[\<\<visit\>\>](visit.md)**
: 일시적으로 다른 노드로 점프했다가 다시 돌아옵니다.

**[\<\<wait\>\>](wait.md)**
: 지정한 시간 동안 대화를 일시 정지합니다.


[user-defined commands]: user_defined_commands.md

```{toctree}
:hidden:

<<character>>          <character.md>
<<declare>>            <declare.md>
<<if>>                 <if.md>
<<jump>>               <jump.md>
<<local>>              <local.md>
<<set>>                <set.md>
<<stop>>               <stop.md>
<<visit>>              <visit.md>
<<wait>>               <wait.md>
사용자 정의 명령       <user_defined_commands.md>
```
