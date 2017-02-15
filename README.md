
 
# Comments
<p>Comments can be made in one of three ways</p>
- Started by `/*`, and ended by `*/`.
- Started by `//`, and ended by the end of the line.
- Started by `#`, and ended by the end of the line.

# Types
<p>There are Four basic Types</p>

### Number
<p>Note: There is no distinction between Integers and Floating Point numbers</p>
- `500`
- `3.5`
- `0xA`
 - Numbers starting with `0<SOMETHING>` use different bases depending on the `<SOMETHING>`

### Text
<p>You can start and end text with any of: <code>'</code>, <code>"</code>, <code>`</code> - they all act the same</p>
- `'I\'m a text'`
 - Characters following a `\` have special meaning
- `"Spam & eggs"`
- ``` `Also a text` ```

### Symbol
<p>Similar to <code>Text</code>, except you can only have alphanumeric values and no spaces.</p>
- `myVariable_0`
- `my_variable`
- `MY_VARIABLE`
- <S><code>0myvar</code></S>
 - <b>NOT</b> a `Symbol` - you can only start symbols with letters or an underscore

### Universe
<p>These can represent Arrays, Maps, Functions, and Classes.</p>
- These will be covered in a later section (INSERT NUMBER HERE)

# Constants
<p>There are a handful of constants included. To access one, write <code>&lt;CONSTANT_NAME&gt;?</code>, as in <code>true?</code></p>

### Logical
- `true` — True, used in logical operators(LINK)
- `false` — False, used in logical operators(LINK)
- `nil`, `null`, `none` — All equivalent, used to signify a missing value

### Mathematical
- `math_e` — Euler's constant(LINK)
- `math_pi` — π(LINK)
- `math_inf` — ∞
- `math_neg_inf` — -∞

### Miscellaneous
- `missing` — Edge case, used when an operator doesn't return a valid value.

# Operators

### Arithmatic
<p>All of the normal arithmatic operators are available, with <code>**</code> representing exponentiation</p>
- `5 + 9` —> `14`
- `3 - 5` —> `-2`
- `4 ** 3` —> `64`
- `15 % 4` —> `3`
- `2 * 3 - 4` —> `2`
- `<=>` - Comparison. `a <=> b` returns `-1`, `0`, or `1` depending on if `a` is less than, equal to, or greater than `b`
<p>More complicated expressions using parenthesis are covered in the following Universe&lt;INSERT LINK&gt; section</p>

### Logical Operators
<p>All of the normal logical operators are in use</p>
- `==` — equal
- `!=`, `&lt;&gt;` — not equal
- `<`, `>` - Less than, Greater than
- `<=`, `>=` - Less than or equal, Greater than or equal
- `||` - Logical Or. `a || b` will return `a` if `a` is true, `b` otherwise.
- `||` - Logical And. `a && b` will return `a` if `a` is false, `b` otherwise.
<p>`0`, empty strings (`''`, `""`, and ``` `` ```), empty universes (`()`, `{}`, `[]`), `false` and `nil`/`null`/`none` all evaluate to false. Everythign else is true. Custom Classes(LINK) can modify this by implimenting the `__bool` function (LINK</p>
### Assignment
- `=`
- `&gt;`
- `&lt;-`
- `:`
### Miscellaneous
- `.`
 - `.=`
 - `.S`, `.L`, `.G`
- `?`
- `!`
- `@`
 - `@0`
- `;`
- `,`
<!—
# 4a. Universes are created by using any of the three brackets: {([
  {} # an empty universe
  [] # also an empty universe
  () # yet another empty universe
# 4b. Universes don't do anything with their contents until asked
  {1, 2, 3}              # The contents are: `1, 2, 3`
  [a, /* foo */ b]       # The contents are: `a, /* foo */ b`  — NOT `a, b`
  ( 'foo', "Bar", {} )   # The contents are: ` 'foo', "Bar", {} `
# 4c. TO do anything with a Universe, use the `!` 
—>














