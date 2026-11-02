package taskscan;

/** One scanner result: type, lexeme and 1-based line/column. ERROR tokens carry a message. */
public final class Token {
    public final TokenType type;
    public final String lexeme;
    public final int line;
    public final int column;
    public final String message; // only for ERROR, otherwise null

    public Token(TokenType type, String lexeme, int line, int column, String message) {
        this.type = type;
        this.lexeme = lexeme;
        this.line = line;
        this.column = column;
        this.message = message;
    }
}
