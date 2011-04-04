class diddy
{
	static public function systemMillisecs():Number{
		return (new Date).getTime();
	}

	static public function flushKeys():void{
		for( var i:int=0;i<512;++i ){
			bb_input_device.keyStates[i]=0;
		}
	}
}