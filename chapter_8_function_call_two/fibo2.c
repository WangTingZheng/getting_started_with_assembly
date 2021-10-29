int ebx, ecx, edx, eax;

int fibo() {
    if(eax == 1) {
        eax = 1;
        return 1;
    }
    if(eax == 2) {
         eax = 1;
         return 1;
    }
    
    edx = eax;
    
    eax = edx - 1;
    eax = fibo(eax);
    ebx = eax;
    
    eax = edx - 2;
    eax = fibo(eax);
    ecx = eax;
    
    eax = ebx + ecx;
}

int main()
{
	eax = 5;
	fibo();
	
	return eax;
}