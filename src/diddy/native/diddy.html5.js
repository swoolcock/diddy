function systemMillisecs(){
	return new Date().getTime();
}

function flushKeys(){
	for( var i = 0; i < 512; ++i )
	{
		bb_input_device.keyStates[i]=0;
	}
}