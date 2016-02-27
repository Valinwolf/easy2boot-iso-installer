## Adding new ISOs to the list

 

#### To add a single ISO to the list:

1. Copy templates/arch-less to the base isofunct directory
2. Rename arch-less to what ever you want as long as it ends in .inc
3. Replace NAME with the name
4. Replace MENU with the folder name of the menu you want it to appear under
5. Replace URL with the URL of the file

 

#### To add multi-arch distro ISOs to the list:

1. Copy templates/multi-arch to the base isofunct directory
2. Rename multi-arch to what ever you want as long as it ends in .inc
3. Replace NAME with the name
4. Replace MENU with the folder name of the menu you want it to appear under
5. Replace I386_URL with the URL of the 32-bit file
6. Replace AMD64_URL with the URL of the 64-bit file

 

If you need the file to be decompressed after download, change `Post=0` to
`Post="unzip"` or whatever decompression utility is needed. Be sure to include any necessary flags. The file name will be appended to the command and evaluated.
