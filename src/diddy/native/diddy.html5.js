var diddy = new Object();

diddy.systemMillisecs=function(){
	return new Date().getTime();
};

diddy.flushKeys=function(){
	for( var i = 0; i < 512; ++i )
	{
		bb_input_device.keyStates[i]=0;
	}
};