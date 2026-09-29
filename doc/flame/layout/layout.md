<a id="layout"></a>

# 레이아웃

픽셀 좌표로 게임 요소를 직접 배치하는 방식은 단순한 경우에는 잘 동작하지만, HUD나 메뉴처럼
다양한 화면 크기에 맞춰야 하는 UI를 만들 때는 금방 번거로워집니다. Flame의 레이아웃 컴포넌트는
Flutter 레이아웃 시스템의 익숙한 개념(row, column, padding, alignment)을 게임 월드로 가져와서,
위치를 손으로 계산하는 대신 선언적으로 컴포넌트를 배치할 수 있게 해 줍니다.

- [Align 컴포넌트](align_component.md)
- [Row 컴포넌트](row_component.md)
- [Column 컴포넌트](column_component.md)
- [Expanded 컴포넌트](expanded_component.md)
- [Padding 컴포넌트](padding_component.md)

```{toctree}
:hidden:

AlignComponent     <align_component.md>
RowComponent       <row_component.md>
ColumnComponent    <column_component.md>
Expanded 컴포넌트  <expanded_component.md>
Padding 컴포넌트   <padding_component.md>
```
