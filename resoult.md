# Test Results and Expected Outputs

This document records the expected results written before running tests, references the test input and expected output text files, documents corrected tests for identified bugs, and reports feature limitations honestly.

---

## 1. Summary of Test Cases & Expected Results

The test inputs are stored in [`test/input/`](file:///Z:/Year%204/Compilation/project%201/lab-project01-compilation/test/input) and their expected outputs are stored as plain text files in [`test/expected/`](file:///Z:/Year%204/Compilation/project%201/lab-project01-compilation/test/expected).

| Test File | Category | Description | Expected Tokens | Expected Errors | Expected Exit Code | Expected Result |
| :--- | :--- | :--- | :---: | :---: | :---: | :--- |
| [`normal_tests.txt`](file:///Z:/Year%204/Compilation/project%201/lab-project01-compilation/test/input/normal_tests.txt) | Normal | Standard commands, keywords, identifiers, strings, operators, comments | 28 | 0 | `0` | **PASS** |
| [`boundary_tests.txt`](file:///Z:/Year%204/Compilation/project%201/lab-project01-compilation/test/input/boundary_tests.txt) | Boundary | Keyword prefixes (`added`), standalone operators (`<=`), missing trailing newline | 6 | 0 | `0` | **PASS** |
| [`invalid_tests.txt`](file:///Z:/Year%204/Compilation/project%201/lab-project01-compilation/test/input/invalid_tests.txt) | Invalid | Unknown characters (`@`, `$`), unterminated string (`"Read`), lone exclamation (`!`) | 10 | 4 | `1` | **PASS (Errors caught)** |

---

## 2. Test Input & Expected Output Text Files

The test suite maintains standalone text files for inputs and expected outputs:
- **Normal Tests:**
  - Input: [`test/input/normal_tests.txt`](file:///Z:/Year%204/Compilation/project%201/lab-project01-compilation/test/input/normal_tests.txt)
  - Expected Output: [`test/expected/normal_tests.out`](file:///Z:/Year%204/Compilation/project%201/lab-project01-compilation/test/expected/normal_tests.out)
- **Boundary Tests:**
  - Input: [`test/input/boundary_tests.txt`](file:///Z:/Year%204/Compilation/project%201/lab-project01-compilation/test/input/boundary_tests.txt)
  - Expected Output: [`test/expected/boundary_tests.out`](file:///Z:/Year%204/Compilation/project%201/lab-project01-compilation/test/expected/boundary_tests.out)
- **Invalid Tests:**
  - Input: [`test/input/invalid_tests.txt`](file:///Z:/Year%204/Compilation/project%201/lab-project01-compilation/test/input/invalid_tests.txt)
  - Expected Output: [`test/expected/invalid_tests.out`](file:///Z:/Year%204/Compilation/project%201/lab-project01-compilation/test/expected/invalid_tests.out)

### 2.1. Expected Output for `normal_tests.txt`
```text
TYPE         LEXEME                    LINE   COL
KEYWORD      add                          1     1
IDENTIFIER   task_7                       1     5
STRING       "Read chapter 4"             1    12
SEMICOLON    ;                            1    28
KEYWORD      done                         2     1
IDENTIFIER   task_7                       2     6
SEMICOLON    ;                            2    12
KEYWORD      list                         3     1
IDENTIFIER   priority                     3     6
GE           >=                           3    15
INTEGER      3                            3    18
SEMICOLON    ;                            3    19
IDENTIFIER   delete                       4     1
IDENTIFIER   a                            4     8
COMMA        ,                            4     9
IDENTIFIER   b                            4    11
COMMA        ,                            4    12
IDENTIFIER   c                            4    14
SEMICOLON    ;                            4    15
KEYWORD      list                         6     1
SEMICOLON    ;                            6     5
KEYWORD      add                          7     1
IDENTIFIER   t1                           7     5
STRING       "A"                          7     8
SEMICOLON    ;                            7    11
KEYWORD      done                         8     1
IDENTIFIER   t1                           8     6
SEMICOLON    ;                            8     8
EOF          <EOF>                        8     9
Summary: 28 tokens, 0 errors
```

### 2.2. Expected Output for `boundary_tests.txt`
```text
TYPE         LEXEME                    LINE   COL
KEYWORD      add                          1     1
SEMICOLON    ;                            1     4
IDENTIFIER   added                        2     1
KEYWORD      add                          2     7
LE           <=                           3     1
KEYWORD      list                         4     1
EOF          <EOF>                        4     5
Summary: 6 tokens, 0 errors
```

### 2.3. Expected Output for `invalid_tests.txt`
```text
TYPE         LEXEME                    LINE   COL
KEYWORD      add                          1     1
ERROR        @                            1     5  unexpected character '@'
SEMICOLON    ;                            1     6
KEYWORD      add                          2     1
ERROR        "Read                        2     5  unterminated string literal
KEYWORD      list                         3     1
ERROR        $                            3     6  unexpected character '$'
IDENTIFIER   x                            3     7
SEMICOLON    ;                            3     8
KEYWORD      done                         4     1
IDENTIFIER   t1                           4     6
ERROR        !                            4     9  unexpected character '!'
INTEGER      3                            4    11
SEMICOLON    ;                            4    12
EOF          <EOF>                        4    13
Summary: 10 tokens, 4 errors
```

---

## 3. Bug Analysis and Corrected Tests

### Bug 1: Escaped Quotes in String Literals
- **Bug Description:** Under naive string regular expressions (such as `\" [^\"\r\n]* \"`), an escaped quote `\"` inside a string literal prematurely closed the string. The remaining text up to the next quote was then parsed as identifiers or unexpected characters, resulting in false syntax errors.
- **Root Cause:** The character class `[^\"\r\n]` excluded quotes without allowing backslash escape pairs.
- **Scanner Fix:**
  ```jflex
  StringChar = [^\"\\\r\n] | \\ [^\r\n]
  String     = \" {StringChar}* \"
  ```
- **Corrected Test:**
  - Input:
    ```text
    add t1 "say \"hi\"";
    ```
  - Expected Output:
    ```text
    TYPE         LEXEME                    LINE   COL
    KEYWORD      add                          1     1
    IDENTIFIER   t1                           1     5
    STRING       "say \"hi\""                 1     8
    SEMICOLON    ;                            1    20
    EOF          <EOF>                        1    21
    Summary: 4 tokens, 0 errors
    ```
  - Result: Correctly tokenized as a single `STRING` token with 0 errors.

### Bug 2: Keyword Prefix vs. Identifier Longest Match
- **Bug Description:** An identifier that begins with a keyword prefix (e.g. `added` starting with keyword `add`) could be misclassified if keywords are matched without respecting identifier length.
- **Corrected Test (`boundary_tests.txt`, line 2):**
  - Input:
    ```text
    added add
    ```
  - Expected Output:
    ```text
    IDENTIFIER   added                        2     1
    KEYWORD      add                          2     7
    ```
  - Result: JFlex's longest match rule ensures `added` (5 chars) is an `IDENTIFIER`, and `add` (3 chars) is a `KEYWORD`.

### Bug 3: `delete` Command vs `remove` Keyword
- **Bug Description:** In `normal_tests.txt`, line 4 uses `delete a, b, c;`. Because `delete` is not listed in the language keywords (`add`, `done`, `remove`, `list`, `show`, `where`), it was scanned as an `IDENTIFIER`.
- **Corrected Test:**
  - Original: `delete a, b, c;` -> `IDENTIFIER delete`
  - Corrected: `remove a, b, c;` -> `KEYWORD remove`

---

## 4. Honest Report of Incomplete Features & Limitations

1. **Numeric Limitations:**
   - Only non-negative integers (`[0-9]+`) are supported.
   - Decimals (`2.5`) and negative numbers (`-5`) are not supported as single tokens (`2.5` is scanned as `INTEGER 2`, `ERROR '.'`, `INTEGER 5`).
2. **Escape Sequence Decoding:**
   - Escape sequences (e.g., `\n`, `\t`, `\"`) are kept literally in the token lexeme and are not decoded into their underlying byte representations.
3. **Trailing Backslash at Line End:**
   - A string ending in a lone backslash at the end of a line (e.g. `"abc\`) is reported as an unterminated string followed by an unexpected character error for `\`.
4. **Unicode Column Counting:**
   - Column positions are based on UTF-16 code units (characters). Supplementary characters outside the BMP (such as 4-byte emojis) increment column counters by 2.
5. **No Parsing / Execution:**
   - TaskScan is strictly a lexical analyzer (scanner). It does not validate grammatical structure (parsing) or execute commands.
