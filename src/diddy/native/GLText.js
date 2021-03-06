function GLText(){
	this.image = new Image;
	this.font = "";
	this.size = 0;
	this.text = "";
	this.textWidth = 0;
	return this;
}

GLText.GetNewInstance=function()
{
	return new GLText();
}

GLText.prototype.SetSize=function(size)
{
	this.size = size;
}

GLText.prototype.GetSize=function()
{
	return this.size;
}

GLText.prototype.Load=function(font, size, xpad, ypad)
{
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
	bb_graphics_context.p_Validate();
	
	ctx.font = this.size + 'px "'+this.font+'"';
	ctx.textBaseline = 'top';
	ctx.fillText(text, x, y);
}

GLText.prototype.DrawTexture=function(x, y)
{
	this.Draw(this.text, x, y);
}

GLText.prototype.CalcWidth=function(text)
{
	var canvas = document.getElementById( "GameCanvas" );
	var ctx = canvas.getContext('2d');
	ctx.font = this.size + 'px "'+this.font+'"';
	this.textWidth = ctx.measureText(text).width;

	return this.textWidth;
}