function GLText(){
	this.image = new Image;
	this.font = "";
	this.size = 0;
	this.text = "";
	return this;
}

GLText.GetNewInstance=function()
{
	return new GLText();
}

GLText.prototype.Load=function(font, size, xpad, ypad)
{
	print("here");
	this.font = font;
	this.size = size;

	var newStyle = document.createElement('style');

	newStyle.appendChild(document.createTextNode("\
	@font-face {\
		font-family: '" + font + "';\
		src: url('data/" + font + "');\
	}\
	"));
	document.head.appendChild(newStyle);
	
	return true;
}

GLText.prototype.CreateText=function(font, text, size)
{
	this.font = font
	this.text = text;
	this.size = size;
	this.Load(font, size, 0, 0);
	return true;
}

GLText.prototype.Draw=function(text, x, y)
{
	var canvas = document.getElementById( "GameCanvas" );
	var ctx = canvas.getContext('2d');
	//ctx.font = this.size + 'px "Vast Shadow"';
	ctx.font = this.size + 'px "'+this.font+'"';
	ctx.textBaseline = 'top';
	ctx.fillText(text, x, y);	
}

GLText.prototype.DrawTexture=function(x, y)
{
	this.Draw(this.text, x, y);
}