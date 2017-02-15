 
1. Comments can be made in one of three ways:
  - Started by `/*`, and ended by `*/`.
  - Started by `//`, and ended by the end of the line.
  - Started by `#`, and ended by the end of the line.

2. There are Four basic `Types`:
  1. `Number` -- There is no distinction between Integers and Floating Point numbers
    - `500`
    - `3.5`
    - `0xA`

  2. `Text` -- You can start and end text with any of: `\`'"`4 - they all act the same */
    'I\'m a text'    # Characters following a \ have special meaning
    "Spam & eggs"
    `Alsi a text`

  /* 2.3 Symbol -- Similar to text, except you can only have alphanumeric values and no spaces. */
    myVariable_0
    my_variable
    MY_VARIABLE
    0myvar # NOT a symbol - you can only start symbols with letters or an underscore

  /* 2.4 Universe -- These can represent Arrays, Maps, Functions, and Classes.  */
    # These will be covered in a later section (INSERT NUMBER HERE)
    # 4a. Universes are created by using any of the three brackets: {([
      {} # an empty universe
      [] # also an empty universe
      () # yet another empty universe
    # 4b. Universes don't do anything with their contents until asked
      {1, 2, 3}              # The contents are: `1, 2, 3`
      [a, /* foo */ b]       # The contents are: `a, /* foo */ b`  -- NOT `a, b`
      ( 'foo', "Bar", {} )   # The contents are: ` 'foo', "Bar", {} `
    # 4c. TO do anything with a Universe, use the `!` 















