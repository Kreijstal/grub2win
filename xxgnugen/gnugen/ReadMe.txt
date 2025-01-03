
        This is the procedure to customize the GNU Grub2 modules for use with Grub2Win

                           
				  *** Warning ***

        The modules supplied with Grub2Win will work on nearly every system. You should only
        run this procedure if you have a specific need. You may render your system unbootable!!
       
			 Please ensure that you have proper backups.



        It is assumed that you have unzipped the C:\grub2\winsource\xxgnugen.zip file
        and placed it on your C: drive as C:\gnugen

        You will need the Current GNU Grub Windows release directory.
	The GNU Grub Windows code is available here (as of February 12, 2024)

	https://ftp.gnu.org/gnu/grub/grub-2.12-for-windows.zip

        Download and unzip the grub-2.12-for-windows directory. 

        Copy it to the C:\gnugen directory as C:\gnugen\grub-2.12-for-windows

        Edit the C:\gnugen\gen-image.bat file:

             Check the "releaselib" variable to ensure that it
             reflects the current release library name.

             Change the "targetgrub" variable to the grub2 target
             directory you wish to update (usually C:\grub2).

             Make any changes to the "efimods" and "biosmods" variables
             to remove or include modules you require.

        Now run gen-image.bat

        It runs quickly and will display progress messages.

        Check the output.xxxxx.txt files if there are any errors to determine what went wrong.

        If there are no errors, you will have the option to update your C:\grub2 directory.

            The newly generated BIOS and EFI boot modules will be copied to C:\grub2\g2bootmgr 

            The current i386-pc, i386-efi and X86_64-efi libraries will be copied to your C:\grub2 directory.

        For EFI systems, you must now run grub2win.exe and click the "Manage EFI Partition Modules" button.
        This will copy the newly updated boot modules from C:\grub2\g2bootmgr to your EFI partition.

        Now reboot your system and you will be running the new code.
