import android.graphics.Typeface;
import android.graphics.Paint;

// GLText converted to Monkey from:
// http://fractiousg.blogspot.com.au/2012/04/rendering-text-in-opengl-on-android.html


class GLText{
	gxtkSurface surface;

	//--Constants--//
	public final static int CHAR_START = 32;           // First Character (ASCII Code)
	public final static int CHAR_END = 126;            // Last Character (ASCII Code)
	public final static int CHAR_CNT = ( ( ( CHAR_END - CHAR_START ) + 1 ) + 1 );  // Character Count (Including Character to use for Unknown)

	public final static int CHAR_NONE = 32;            // Character to Use for Unknown (ASCII Code)
	public final static int CHAR_UNKNOWN = ( CHAR_CNT - 1 );  // Index of the Unknown Character

	public final static int FONT_SIZE_MIN = 6;         // Minumum Font Size (Pixels)
	public final static int FONT_SIZE_MAX = 180;       // Maximum Font Size (Pixels)

	public final static int CHAR_BATCH_SIZE = 100;     // Number of Characters to Render Per Batch

	int fontPadX, fontPadY;                            // Font Padding (Pixels; On Each Side, ie. Doubled on Both X+Y Axis)

	float fontHeight;                                  // Font Height (Actual; Pixels)
	float fontAscent;                                  // Font Ascent (Above Baseline; Pixels)
	float fontDescent;                                 // Font Descent (Below Baseline; Pixels)

	int textureSize;                                   // Texture Size for Font (Square)

	float charWidthMax;                                // Character Width (Maximum; Pixels)
	float charHeight;                                  // Character Height (Maximum; Pixels)
	final float[] charWidths;                          // Width of Each Character (Actual; Pixels)
	TextureRegion[] charRgn;                           // Region of Each Character (Texture Coordinates)
	int cellWidth, cellHeight;                         // Character Cell Width/Height

	float scaleX, scaleY;                              // Font Scale (X,Y Axis)
	float spaceX;  

	Activity activity;
	Context context;
	AssetManager assets;
	
	static public GLText GetNewInstance(){
		return new GLText();
	}
	
	public GLText() {
		activity = BBAndroidGame.AndroidGame().GetActivity();
		context = activity.getApplicationContext();
		
		surface = new gxtkSurface();
		
		assets = context.getAssets();
		
		charWidths = new float[CHAR_CNT];               // Create the Array of Character Widths
		charRgn = new TextureRegion[CHAR_CNT];          // Create the Array of Character Regions

		// initialize remaining members
		fontPadX = 0;
		fontPadY = 0;

		fontHeight = 0.0f;
		fontAscent = 0.0f;
		fontDescent = 0.0f;

		textureSize = 0;

		charWidthMax = 0;
		charHeight = 0;

		cellWidth = 0;
		cellHeight = 0;

		scaleX = 1.0f;                                  // Default Scale = 1 (Unscaled)
		scaleY = 1.0f;                                  // Default Scale = 1 (Unscaled)
		spaceX = 0.0f;
	}
	
	public boolean Load(String file, int size, int padX, int padY){
		// Append monkey folder!!!
		file = "monkey/"+file;
		
		// load the font and setup paint instance for drawing
		Typeface tf = Typeface.createFromAsset( assets, file );  // Create the Typeface from Font File
		Paint paint = new Paint();                      // Create Android Paint Instance
		paint.setAntiAlias( true );                     // Enable Anti Alias
		paint.setTextSize( size );                      // Set Text Size
		paint.setColor( 0xffffffff );                   // Set ARGB (White, Opaque)
		paint.setTypeface( tf );                        // Set Typeface
		
		// get font metrics
		Paint.FontMetrics fm = paint.getFontMetrics();  // Get Font Metrics
		fontHeight = (float)Math.ceil( Math.abs( fm.bottom ) + Math.abs( fm.top ) );  // Calculate Font Height
		fontAscent = (float)Math.ceil( Math.abs( fm.ascent ) );  // Save Font Ascent
		fontDescent = (float)Math.ceil( Math.abs( fm.descent ) );  // Save Font Descent
		
		// determine the width of each character (including unknown character)
		// also determine the maximum character width
		char[] s = new char[2];                         // Create Character Array
		charWidthMax = charHeight = 0;                  // Reset Character Width/Height Maximums
		float[] w = new float[2];                       // Working Width Value
		int cnt = 0;                                    // Array Counter
		for ( char c = CHAR_START; c <= CHAR_END; c++ )  {  // FOR Each Character
			s[0] = c;                                    // Set Character
			paint.getTextWidths( s, 0, 1, w );           // Get Character Bounds
			charWidths[cnt] = w[0];                      // Get Width
			if ( charWidths[cnt] > charWidthMax )        // IF Width Larger Than Max Width
				charWidthMax = charWidths[cnt];           // Save New Max Width
			cnt++;                                       // Advance Array Counter
		}
		s[0] = CHAR_NONE;                               // Set Unknown Character
		paint.getTextWidths( s, 0, 1, w );              // Get Character Bounds
		charWidths[cnt] = w[0];                         // Get Width
		if ( charWidths[cnt] > charWidthMax )           // IF Width Larger Than Max Width
			charWidthMax = charWidths[cnt];              // Save New Max Width
		cnt++;                                          // Advance Array Counter

		// set character height to font height
		charHeight = fontHeight;                        // Set Character Height

		// find the maximum size, validate, and setup cell sizes
		cellWidth = (int)charWidthMax + ( 2 * fontPadX );  // Set Cell Width
		cellHeight = (int)charHeight + ( 2 * fontPadY );  // Set Cell Height
		int maxSize = cellWidth > cellHeight ? cellWidth : cellHeight;  // Save Max Size (Width/Height)
		if ( maxSize < FONT_SIZE_MIN || maxSize > FONT_SIZE_MAX )  // IF Maximum Size Outside Valid Bounds
			return false;                                // Return Error

		// set texture size based on max font size (width or height)
		// NOTE: these values are fixed, based on the defined characters. when
		// changing start/end characters (CHAR_START/CHAR_END) this will need adjustment too!
		if ( maxSize <= 24 )                            // IF Max Size is 18 or Less
			textureSize = 256;                           // Set 256 Texture Size
		else if ( maxSize <= 40 )                       // ELSE IF Max Size is 40 or Less
			textureSize = 512;                           // Set 512 Texture Size
		else if ( maxSize <= 80 )                       // ELSE IF Max Size is 80 or Less
			textureSize = 1024;                          // Set 1024 Texture Size
		else                                            // ELSE IF Max Size is Larger Than 80 (and Less than FONT_SIZE_MAX)
			textureSize = 2048;                          // Set 2048 Texture Size
		
		// create an empty bitmap (alpha only)
		Bitmap bitmap = Bitmap.createBitmap( textureSize, textureSize, Bitmap.Config.ARGB_8888 );//Bitmap.Config.ALPHA_8 );  // Create Bitmap
		Canvas canvas = new Canvas( bitmap );           // Create Canvas for Rendering to Bitmap
		bitmap.eraseColor( 0x00000000 );                // Set Transparent Background (ARGB)

		// render each of the characters to the canvas (ie. build the font map)
		float x = fontPadX;                             // Set Start Position (X)
		float y = ( cellHeight - 1 ) - fontDescent - fontPadY;  // Set Start Position (Y)
		for ( char c = CHAR_START; c <= CHAR_END; c++ )  {  // FOR Each Character
			s[0] = c;                                    // Set Character to Draw
			canvas.drawText( s, 0, 1, x, y, paint );     // Draw Character
			x += cellWidth;                              // Move to Next Character
			if ( ( x + cellWidth - fontPadX ) > textureSize )  {  // IF End of Line Reached
				x = fontPadX;                             // Set X for New Row
				y += cellHeight;                          // Move Down a Row
			}
		}
		s[0] = CHAR_NONE;                               // Set Character to Use for NONE
		
		canvas.drawText( s, 0, 1, x, y, paint );        // Draw Character
		surface.SetBitmap( bitmap );

		// setup the array of character texture regions
		x = 0;                                          // Initialize X
		y = 0;                                          // Initialize Y
		for ( int c = 0; c < CHAR_CNT; c++ )  {         // FOR Each Character (On Texture)
			charRgn[c] = new TextureRegion( textureSize, textureSize, x, y, cellWidth-1, cellHeight-1 );  // Create Region for Character
			x += cellWidth;                              // Move to Next Char (Cell)
			if ( x + cellWidth > textureSize )  {
				x = 0;                                    // Reset X Position to Start
				y += cellHeight;                          // Move to Next Row (Cell)
			}
		}
		
		return true;
	}
	
	public void Draw(String text, float x, float y)  {
		c_GraphicsContext gc = bb_graphics.g_context;

		//FIXME: copied code from c_GraphicsContext.p_Validate() as I can't call it for some reason
		if ((gc.m_matDirty)!=0) {
			bb_graphics.g_renderDevice.SetMatrix(bb_graphics.g_context.m_ix,
								bb_graphics.g_context.m_iy,
								bb_graphics.g_context.m_jx,
								bb_graphics.g_context.m_jy,
								bb_graphics.g_context.m_tx,
								bb_graphics.g_context.m_ty);
			gc.m_matDirty=0;
		}
		
		float chrHeight = cellHeight * scaleY;          // Calculate Scaled Character Height
		float chrWidth = cellWidth * scaleX;            // Calculate Scaled Character Width
		int len = text.length();                        // Get String Length
		x += ( chrWidth / 2.0f ) - ( fontPadX * scaleX );  // Adjust Start X
		y += ( chrHeight / 2.0f ) - ( fontPadY * scaleY );  // Adjust Start Y
		for ( int i = 0; i < len; i++ )  {              // FOR Each Character in String
			int c = (int)text.charAt( i ) - CHAR_START;  // Calculate Character Index (Offset by First Char in Font)
			if ( c < 0 || c >= CHAR_CNT )                // IF Character Not In Font
				c = CHAR_UNKNOWN;                         // Set to Unknown Character Index
			
			bb_graphics.g_renderDevice.DrawSurface2(surface, x, y, charRgn[c].x, charRgn[c].y, charRgn[c].w, charRgn[c].h);

			x += ( charWidths[c] + spaceX ) * scaleX;    // Advance X Position by Scaled Character Width
		}
	}
	
	public void DrawTexture(float x, float y)  {
		bb_graphics.g_renderDevice.DrawSurface(surface, x, y);
	}
}

class TextureRegion {

	//--Members--//
	public float u1, v1;                               // Top/Left U,V Coordinates
	public float u2, v2;                               // Bottom/Right U,V Coordinates

	public int x, y;
	public int w, h;
	
	//--Constructor--//
	// D: calculate U,V coordinates from specified texture coordinates
	// A: texWidth, texHeight - the width and height of the texture the region is for
	//    x, y - the top/left (x,y) of the region on the texture (in pixels)
	//    width, height - the width and height of the region on the texture (in pixels)
	public TextureRegion(float texWidth, float texHeight, float x, float y, float width, float height)  {
		this.x = Math.round(x);
		this.w = Math.round(width);
		this.y = Math.round(y);
		this.h = Math.round(height);
		
		this.u1 = x / texWidth;                         // Calculate U1
		this.v1 = y / texHeight;                        // Calculate V1
		this.u2 = this.u1 + ( width / texWidth );       // Calculate U2
		this.v2 = this.v1 + ( height / texHeight );     // Calculate V2
	}
}
