#include <time.h>

class diddy
{
	public:

	// only accurate to 1 second 
	static int systemMillisecs() {
		time_t seconds;
		seconds = time (NULL);
		return seconds * 1000;
	}

	static void flushKeys() {
		for( int i=0;i<512;++i ){
			app->input->keyStates[i]&=0x100;
		}
	}
	
	static int getUpdateRate() {
		return app->updateRate;
	}
	
	static void showMouse()
	{
		// Empty Stub
	}
	static void hideMouse()
	{
		// Empty Stub
	}
	
};
