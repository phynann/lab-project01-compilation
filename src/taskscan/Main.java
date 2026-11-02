package taskscan;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.io.Reader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

/** Console driver: java taskscan.Main <input-file>. Reads UTF-8, prints one row per token. */
public final class Main {
    public static void main(String[] args) throws IOException {
        if (args.length != 1) {
            System.err.println("usage: java taskscan.Main <input-file>");
            System.exit(2);
        }
        PrintStream out = new PrintStream(System.out, true, StandardCharsets.UTF_8);
        int tokens = 0, errors = 0;
        out.println(String.format("%-12s %-24s %5s %5s", "TYPE", "LEXEME", "LINE", "COL"));
        try (Reader in = new InputStreamReader(Files.newInputStream(Paths.get(args[0])), StandardCharsets.UTF_8)) {
            TaskScanner scanner = new TaskScanner(in);
            Token t;
            boolean first = true;
            while (true) {
                t = scanner.yylex();
                String row = String.format("%-12s %-24s %5d %5d", t.type, t.lexeme, t.line, t.column);
                if (t.type == TokenType.ERROR) {
                    errors++;
                    row += "  " + t.message;
                } else if (t.type != TokenType.EOF) {
                    tokens++;
                }
                out.println(row);
                if (t.type == TokenType.EOF) break;
            }
        } catch (IOException e) {
            System.err.println("cannot read " + args[0] + ": " + e.getMessage());
            System.exit(2);
        }
        out.println("Summary: " + tokens + " tokens, " + errors + " errors");
        System.exit(errors > 0 ? 1 : 0);
    }
}
