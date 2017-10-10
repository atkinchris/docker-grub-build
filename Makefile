build:
	$(eval tmp := builder)
	docker build -t $(tmp) .
	docker run --privileged -v `pwd`/output:/tmp/output -it $(tmp)

grub:
	grub-mkimage -o bootx64.efi -p /efi/boot -O x86_64-efi \
    fat iso9660 part_gpt part_msdos \
    normal boot linux configfile loopback chain \
    efifwsetup efi_gop efi_uga \
    ls search search_label search_fs_uuid search_fs_file \
    gfxterm gfxterm_background gfxterm_menu test all_video loadenv \
    exfat ext2 ntfs btrfs hfsplus udf

build-floppy:
	dd bs=512 count=2880 if=/dev/zero of=floppy.img
	mkfs.msdos floppy.img
	mkdir -p /media/floppy
	mount -o loop floppy.img /media/floppy/
	mkdir -p /media/floppy/EFI/BOOT
	cp bootx64.efi /media/floppy/EFI/BOOT
	cp grub.cfg /media/floppy/EFI/BOOT
	umount /media/floppy/

build-disk:
	rm -f disk.*
	VBoxManage convertfromraw output/floppy.img disk.vdi --variant Fixed

build-disk-generic:
	rm -f disk.*
	hdiutil create -size 1m -fs FAT32 -volname LINUX -o ./disk
	VBoxManage convertfromraw disk.dmg disk.vdi --variant Fixed
	rm disk.dmg
	ln -s disk.vdi disk.img
	hdiutil attach -section 0x1000 disk.img
