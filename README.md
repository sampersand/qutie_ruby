 
# Comments
<p>Comments can be made in one of three ways</p>
- Started by `/*`, and ended by `*/`.
- Started by `//`, and ended by the end of the line.
- Started by `#`, and ended by the end of the line.

# Types
<p>There are Four basic Types</p>

## Number
<p>Note: There is no distinction between Integers and Floating Point numbers</p>
- `500`
- `3.5`
- `0xA`
 - Numbers starting with `0<SOMETHING>` use different bases depending on the `<SOMETHING>`

## Text
<p>You can start and end text with any of: <code>'</code>, <code>"</code>, <code>`</code> - they all act the same</p>
- `'I\'m a text'`
 - Characters following a `\` have special meaning
- `"Spam & eggs"`
- ``` `Also a text` ```

## Symbol
<p>Similar to <code>Text</code>, except you can only have alphanumeric values and no spaces.</p>
- `myVariable_0`
- `my_variable`
- `MY_VARIABLE`
- <S><code>0myvar</code></S>
 - <b>NOT</b> a `Symbol` - you can only start symbols with letters or an underscore

## Universe
<p>These can represent Arrays, Maps, Functions, and Classes.</p>
- These will be covered in a later section (INSERT NUMBER HERE)




<!--
# 4a. Universes are created by using any of the three brackets: {([
  {} # an empty universe
  [] # also an empty universe
  () # yet another empty universe
# 4b. Universes don't do anything with their contents until asked
  {1, 2, 3}              # The contents are: `1, 2, 3`
  [a, /* foo */ b]       # The contents are: `a, /* foo */ b`  -- NOT `a, b`
  ( 'foo', "Bar", {} )   # The contents are: ` 'foo', "Bar", {} `
# 4c. TO do anything with a Universe, use the `!` 
-->














