#include <stdio.h>
#include <iostream.h>

void main(void)
{
	int j,k = 0;

	for (j=0;j<16;j++)
	{
		cout << "      <TR>\n";
		for (k=0;k<16;k++)
		{
			cout << "        <TD>&#" << 16*j+k << ";</TD>\n";
		}
		cout << "      </TR>\n";
		for (k=0;k<16;k++)
		{
			cout << "        <TD>&amp;#" << 16*j+k << ";</TD>\n";
		}
		cout << "      </TR>\n";


	}
}
