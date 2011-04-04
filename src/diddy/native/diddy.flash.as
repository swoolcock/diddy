function systemMillisecs():Number{
	return (new Date).getTime();
}

function flushKeys():void{
	for( var i:int=0;i<512;++i ){
		bb_input_device.keyStates[i]=0;
	}
}