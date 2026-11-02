package taskscan;

/** All token kinds produced by the TaskScan scanner (plus ERROR and EOF markers). */
public enum TokenType {
    KEYWORD, IDENTIFIER, INTEGER, STRING,
    ASSIGN, EQ, NE, LT, LE, GT, GE,
    SEMICOLON, COMMA,
    ERROR, EOF
}
