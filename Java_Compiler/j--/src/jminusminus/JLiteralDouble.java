// Copyright 2012- Bill Campbell, Swami Iyer and Bahar Akbal-Delibas

package jminusminus;

import static jminusminus.CLConstants.*;

/**
 * The AST node for a double literal.
 */
class JLiteralDouble extends JExpression {
    // String representation of the literal.
    private String text;

    /**
     * Constructs an AST node for a double literal given its line number and string representation.
     *
     * @param line line in which the literal occurs in the source file.
     * @param text string representation of the literal.
     */
    public JLiteralDouble(int line, String text) {
        super(line);
        this.text = text;
    }

    /**
     * {@inheritDoc}
     */
    public JExpression analyze(Context context) {
        type = Type.DOUBLE; // project5/problem1 initializing the type to Double and implementing it
        return this; //  project5/problem1 returning the text
    }

    /**
     * {@inheritDoc}
     */
    public void codegen(CLEmitter output) {
        double i = Double.parseDouble(text); //project5/problem1 parsing the text as a double
        // appendix d for help
        if (i == 0D) { //project5/problem1 making if-else case if i = 0 for output in DCONST_0
            output.addNoArgInstruction(DCONST_0);
        } else if (i == 1D) { //project5/problem1 making if-else case if i = 1 for output in DCONST_1
            output.addNoArgInstruction(DCONST_1);
        } else { //project5/problem1 else case to otherwise add the DC instructions
            output.addLDCInstruction(i);
        }
    }

    /**
     * {@inheritDoc}
     */
    public void toJSON(JSONElement json) {
        JSONElement e = new JSONElement();
        json.addChild("JLiteralDouble:" + line, e);
        e.addAttribute("type", type == null ? "" : type.toString());
        e.addAttribute("value", text);
    }
}
