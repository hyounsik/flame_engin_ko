<a id="variables"></a>

# 변수

**변수**는 어떤 정보를 저장하는 장소입니다. 다른 프로그래밍 언어에서의 개념과 같습니다. 각 변수에는
**이름**, **값**, **타입**, **스코프**가 있습니다.


<a id="name"></a>

## 이름

변수의 **이름**은 `.yarn` 스크립트에서 변수를 가리키는 방법입니다. 모든 변수의 이름은 `$` 기호로
시작하고, 그 뒤에 문자나 밑줄이 오고, 그다음에 문자, 숫자, 밑줄이 몇 개든 올 수 있습니다. 따라서
다음은 모두 유효한 변수 이름입니다.

```text
$i
$WARNING
$_secret_
$door10
$climbed_over_wall_and_avoided_all_guard_patrols
$DoorPassword
```

반면 다음은 유효한 이름이 아닙니다.

```text
$2000_years
$[main]
@today
victory
```


<a id="type"></a>

## 타입

각 변수에는 특정 **타입**이 연결되어 있습니다. 변수의 타입은 변수가 처음 선언될 때 결정되며, 그 후에는
절대 바뀌지 않습니다.

YarnSpinner에는 `string`, `number`, `bool`의 세 가지 변수 타입이 있습니다.

- `bool` 변수는 `true` 또는 `false`만 저장할 수 있습니다.
- `number` 변수는 `0`, `42`, `2.5` 같은 정수나 소수를 담을 수 있습니다.
- `string` 변수는 `"the most random number is 4"` 같은 임의의 텍스트를 담습니다.
```yarn
// Creates a variable $money of type number, and gives it initial value of 100
<<declare $money = 100>>

// Creates variable $name of type string, the initial value will be ""
<<declare $name as String>>
```


<a id="value"></a>

## 값

각 변수는 하나의 **값**을 저장합니다. 이 값은 언제든 다른 값으로 바꿀 수 있지만, 새 값의 타입은
같아야 합니다.

각 변수에는 처음 만들어질 때 초기값이 할당되며, 이후 [\<\<set\>\>][set] 명령으로 새 값을 할당할 수
있습니다.
```yarn
<<set $money += 10>>  // increases the value of $money by 10
```


<a id="scope"></a>

## 스코프

변수의 **스코프**는 변수에 정확히 어디서 접근할 수 있는지를 말합니다. YarnSpinner에서 변수는 전역이거나
지역일 수 있습니다.

- **전역** 변수는 [\<\<declare\>\>][declare] 명령으로 도입되며, 한번 만들어지면 어디서든 접근할 수
  있습니다. 모든 전역 변수의 이름은 고유합니다.
- **지역** 변수는 [\<\<local\>\>][local] 명령으로 만들어지며, 만들어진 노드 안에서만 사용할 수 있습니다.
  서로 다른 노드에 같은 이름의 지역 변수를 둘 수 있으며, 이들은 서로 다른 변수로 간주됩니다.
```yarn
<<declare $global_variable = 0>>

title: MyNode
---
<<local $local_variable = 1>>
===
```


[declare]: ../commands/declare.md
[local]: ../commands/local.md
[set]: ../commands/set.md
