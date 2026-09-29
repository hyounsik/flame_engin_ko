<a id="numeric-functions"></a>

# 숫자 함수

이 함수들은 숫자 값을 다루는 데 사용합니다. 대부분은 숫자 인자 하나를 받아 숫자 결과를 만듭니다.


## `ceil(x)`

값 `x`를 양의 무한대 방향으로 올림하여 반환합니다. 다시 말해 `x`보다 크거나 같은 가장 작은 정수 값을
반환합니다.
```yarn
title: ceil
---
{ ceil(0)     }  // 0
{ ceil(0.3)   }  // 1
{ ceil(5)     }  // 5
{ ceil(5.001) }  // 6
{ ceil(5.999) }  // 6
{ ceil(-2.07) }  // -2
===
```

```{seealso}
- [`floor(x)`](#floorx)
- [`int(x)`](#intx)
```


## `dec(x)`

값 `x`를 이전 정수 쪽으로 줄여서 반환합니다. 따라서 `x`가 이미 정수라면 `x - 1`을 반환하고, `x`가
정수가 아니라면 `floor(x)`를 반환합니다.
```yarn
title: dec
---
{ dec(0)     }  // -1
{ dec(0.3)   }  // 0
{ dec(5.0)   }  // 4
{ dec(5.001) }  // 5
{ dec(5.999) }  // 5
{ dec(-2.07) }  // -3
===
```

```{seealso}
- [`inc(x)`](#incx)
```


## `decimal(x)`

`x`의 소수 부분을 반환합니다.

`x`가 양수이면 반환값은 `0`(포함)과 `1`(제외) 사이입니다. `x`가 음수이면 반환값은 `0`과 `-1` 사이입니다.
모든 경우에 `x == int(x) + decimal(x)`가 성립해야 합니다.
```yarn
title: decimal
---
{ decimal(0)     }  // 0
{ decimal(0.3)   }  // 0.3
{ decimal(5.0)   }  // 0
{ decimal(5.001) }  // 0.001
{ decimal(5.999) }  // 0.999
{ decimal(-2.07) }  // -0.07
===
```

```{seealso}
- [`int(x)`](#intx)
```


## `floor(x)`

값 `x`를 음의 무한대 방향으로 내림하여 반환합니다. 다시 말해 `x`보다 작거나 같은 가장 큰 정수 값을
반환합니다.
```yarn
title: floor
---
{ floor(0)     }  // 0
{ floor(0.3)   }  // 0
{ floor(5)     }  // 5
{ floor(5.001) }  // 5
{ floor(5.999) }  // 5
{ floor(-2.07) }  // -3
===
```

```{seealso}
- [`ceil(x)`](#ceilx)
- [`int(x)`](#intx)
```


## `inc(x)`

값 `x`를 다음 정수 쪽으로 늘려서 반환합니다. 따라서 `x`가 이미 정수라면 `x + 1`을 반환하고, `x`가
정수가 아니라면 `ceil(x)`를 반환합니다.
```yarn
title: inc
---
{ inc(0)     }  // 1
{ inc(0.3)   }  // 1
{ inc(5.0)   }  // 6
{ inc(5.001) }  // 6
{ inc(5.999) }  // 6
{ inc(-2.07) }  // -2
===
```

```{seealso}
- [`dec(x)`](#decx)
```


## `int(x)`

`x`의 소수 부분을 잘라 0 방향으로 반올림하고, 인자 `x`의 정수 부분만 반환합니다.
```yarn
title: int
---
{ int(0)     }  // 0
{ int(0.3)   }  // 0
{ int(5.0)   }  // 5
{ int(5.001) }  // 5
{ int(5.999) }  // 5
{ int(-2.07) }  // -2
===
```

```{seealso}
- [`decimal(x)`](#decimalx)
- [`round(x)`](#roundx)
```


## `round(x)`

값 `x`를 가장 가까운 정수로 반올림합니다.

`.5`로 끝나는 값은 `x`가 양수이면 올림하고, 음수이면 내림합니다.
```yarn
title: round
---
{ round(0)     }  // 0
{ round(0.3)   }  // 0
{ round(5.0)   }  // 5
{ round(5.001) }  // 5
{ round(5.5)   }  // 6
{ round(5.999) }  // 6
{ round(-2.07) }  // -2
{ round(-2.5) }   // -3
===
```

```{seealso}
- [`round_places(x, n)`](#round_placesx-n)
```


## `round_places(x, n)`

값 `x`를 소수점 아래 `n`자리로 반올림합니다.

값 `x`는 양수, 음수, 0 모두 될 수 있지만 정수여야 합니다. 소수점 아래 `0`자리로 반올림하는 것은 일반
`round(x)` 함수와 같습니다. `n`이 양수이면 함수는 `x`의 소수점 뒤 자릿수를 그만큼 유지하려고 합니다.
`n`이 음수이면 `round_places()`는 `x`를 가장 가까운 십, 백, 천 등의 단위로 반올림합니다.
```yarn
title: round_places
---
{ round_places(0, 1)     }  // 0
{ round_places(0.3, 1)   }  // 0.3
{ round_places(5.001, 1) }  // 5.0
{ round_places(5.001, 2) }  // 5.0
{ round_places(5.001, 3) }  // 5.001
{ round_places(5.5, 1)   }  // 5.5
{ round_places(5.999, 1) }  // 6.0
{ round_places(-2.07, 1) }  // -2.1
{ round_places(13, -1)   }  // 10
{ round_places(252, -2)  }  // 200
===
```

```{seealso}
- [`round(x)`](#roundx)
```
