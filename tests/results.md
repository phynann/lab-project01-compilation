| Test | Kind | Input (escaped) | Result |
|------|------|-----------------|--------|
| B01 | boundary | `''` | PASS |
| B02 | boundary | `'add added address done_ donex\n'` | PASS |
| B03 | boundary | `'a>=b>c<=d<e==f=g!=h\n'` | PASS |
| B04 | boundary | `'show7;7show'` | PASS |
| B05 | boundary | `'\tdone\tt1;\r\n# bye'` | PASS |
| B06 | boundary | `'add t1 "say \\"hi\\"";\n'` | PASS |
| E01 | invalid | `'add t1 @ "x";\n'` | PASS |
| E02 | invalid | `'add t1 "Read chapter\nlist;\n'` | PASS |
| E03 | invalid | `'x ! y\n'` | PASS |
| E04 | invalid | `'show t1 2.5;\n'` | PASS |
| N01 | normal | `'add task_7 "Read chapter 4";\n'` | PASS |
| N02 | normal | `'done task_7;\n'` | PASS |
| N03 | normal | `'list;\nshow task_7;\n'` | PASS |
| N04 | normal | `'# weekly plan\nadd t1 "Write report"; # due soon\nremove t1;\n'` | PASS |
| N05 | normal | `'list where priority >= 3;\nshow t1, t2, t3;\n'` | PASS |
| N06 | normal | `'add t9 "café ☕ 日本";\n'` | PASS |

Total: 16 tests, 16 passed, 0 failed
