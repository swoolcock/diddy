/*
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
package diddy;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

import javax.imageio.ImageIO;

public class FontBuilder {
  public static void main(String[] args) throws IOException {
    PrintWriter pw = new PrintWriter(new FileWriter("fonts.xml"), true);
    pw.printf("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<fonts>\n");
    writeFont(pw, "Tahoma-10", "tahoma_10.png", "tahoma_10_black.png", "Tahoma", Font.PLAIN, 10, 256, 128);
    writeFont(pw, "Tahoma-Bold-10", "tahoma_bold_10.png", "tahoma_bold_10_black.png", "Tahoma", Font.BOLD, 10, 256, 128);
    writeFont(pw, "Tahoma-12", "tahoma_12.png", "tahoma_12_black.png", "Tahoma", Font.PLAIN, 12, 256, 128);
    writeFont(pw, "Tahoma-Bold-12", "tahoma_bold_12.png", "tahoma_bold_12_black.png", "Tahoma", Font.BOLD, 12, 256, 128);
    pw.printf("</fonts>\n");
    pw.close();
  }

  /**
   * @param name        The name to display in the XML, used as the key in the Font.fonts StringMap in font.monkey
   * @param atlas       The target png for the atlas (white text)
   * @param blackAtlas  The target png for the atlas (black text)
   * @param face        The font name (as known to Java)
   * @param style       The font style (using Font constants)
   * @param size        Font size in points
   * @param width       Width of the final image
   * @param height      Height of the final image
   */
  public static void writeFont(PrintWriter pw, String name, String atlas, String blackAtlas, String face, int style,
      int size, int width, int height) {
    BufferedImage bi1 = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
    BufferedImage bi2 = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
    Graphics2D g1 = (Graphics2D) bi1.getGraphics();
    Graphics2D g2 = (Graphics2D) bi2.getGraphics();
    Font font = new Font(face, style, size);
    Rectangle2D bounds = font.getMaxCharBounds(g1.getFontRenderContext());
    int maxCharWidth = (int) Math.ceil(bounds.getWidth());
    int maxCharHeight = (int) Math.ceil(bounds.getHeight());
    int charsPerRow = width / maxCharWidth;

    g1.setFont(font);
    g1.setColor(Color.white);
    g2.setFont(font);
    g2.setColor(Color.black);

    pw.printf("\t<font name=\"%s\" atlas=\"%s\" blackAtlas=\"%s\">\n", name, atlas, blackAtlas);
    int x = 0, y = 0;
    for (int i = 32; i < 128; i++) {
      String str = Character.toString((char) i);
      Rectangle2D rect = font.getStringBounds(str, g1.getFontRenderContext());
      g1.drawString(Character.toString((char) i), x * maxCharWidth, y * maxCharHeight - (int) Math.ceil(rect.getY()));
      g2.drawString(Character.toString((char) i), x * maxCharWidth, y * maxCharHeight - (int) Math.ceil(rect.getY()));
      pw.printf(
          "\t\t<glyph code=\"%d\" char=\"%s\" baseline=\"%.2f\" srcX=\"%d\" srcY=\"%d\" srcWidth=\"%d\" srcHeight=\"%d\" />\n",
          i, escapeString(str), -rect.getY(), x * maxCharWidth, y * maxCharHeight, (int) Math.ceil(rect.getWidth()),
          (int) Math.ceil(rect.getHeight()));
      x++;
      if (x >= charsPerRow) {
        x = 0;
        y++;
      }
    }
    pw.printf("\t</font>\n");

    try {
      ImageIO.write(bi1, "png", new File(atlas));
      ImageIO.write(bi2, "png", new File(blackAtlas));
    } catch (IOException e) {
      e.printStackTrace();
    }
    g1.dispose();
    g2.dispose();
  }

  public static String escapeString(String s) {
    s = s.replace("&", "&amp;");
    s = s.replace("\"", "&quot;");
    s = s.replace("'", "&apos;");
    s = s.replace("<", "&lt;");
    s = s.replace(">", "&gt;");
    return s;
  }
}
