int main()
{
	register int a = 1;
	if(a > 1)
	{
		goto next;
	}
	a = a + 2;
next:
	a = a - 1;
	return a;
}