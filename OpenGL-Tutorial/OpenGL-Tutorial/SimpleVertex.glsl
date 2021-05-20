attribute vec4 vPosition;
//attribute float fProgress;

void main()
{
    vec4 test = vPosition;
    
    //if(test.y == 0.5) {  test.y = test.y + 0.02; }
    
	gl_Position = test;
}
