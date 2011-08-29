#!/bin/bash
#Script per l'assemblaggio della ROM
#Simone Di Maio (simone.dimaio77@gmail.com)

appPath=`dirname "$(readlink -f $0)"`
cd $appPath
cd ../../..

export rootPath=`pwd`
export otaFile="$rootPath/$1"
export productFolder="$rootPath/device/htc/dream-sapphire"
export otaFolder="$rootPath/out/otafiles"

export fkernel="EZ2.6.36.4"

echo -n "Which is the name of the ROM? [PadronFroyo] "
read romName

case "$romName" in
	"")
	export romName="PadronFroyo";
	    	
	;;
esac

echo -n "Which is the version of the ROM? "
read romVersion

echo -n "Which is the name of the zip file (without .zip extension)? [$romName$romVersion] "
read romFile

case "$romFile" in
	"")
	export romFile=$romName$romVersion;
	    	
	;;
esac


if [ ! -d $otaFolder ]
then
    mkdir $otaFolder
fi


#INIZIAMO CON LA CREAZIONE DELLA ROM

#creiamo una cartella temporanea dove costruire la ROM
mkdir $otaFolder/tmpfolder
unzip -o $otaFile -d $otaFolder/tmpfolder

#cancelliamo le directory che non ci servono
rm -r $otaFolder/tmpfolder/recovery
rm -r $otaFolder/tmpfolder/META-INF
rm -r $otaFolder/tmpfolder/system/fonts
rm $otaFolder/tmpfolder/boot.img

#aggiungiamo i file nuovi
cp -r -T $productFolder/META-INF $otaFolder/tmpfolder/META-INF

cp -r -T $productFolder/installfiles $otaFolder/tmpfolder/installfiles

cp -r -T $productFolder/prebuilt/fonts $otaFolder/tmpfolder/system/fonts

cp -r -T $productFolder/kernel/$fkernel/modules $otaFolder/tmpfolder/installfiles/modules
cp -r -T $productFolder/kernel/$fkernel/patch $otaFolder/tmpfolder/installfiles/kernel
cp $productFolder/kernel/$fkernel/ebi0_boot.img $otaFolder/tmpfolder/boot.img

cp $productFolder/prebuilt/build.prop $otaFolder/tmpfolder/system
echo ro.build.display.id=$romName$romVersion>>$otaFolder/tmpfolder/system/build.prop




#CREAZIONE E FIRMA DEL FILE ZIP
cd $otaFolder/tmpfolder
zip -r $otaFolder/tmpfolder.zip *
cd $rootPath

java -jar $rootPath/out/host/linux-x86/framework/signapk.jar $rootPath/build/target/product/security/testkey.x509.pem $rootPath/build/target/product/security/testkey.pk8 $otaFolder/tmpfolder.zip $otaFolder/$romFile.zip

rm -r $otaFolder/tmpfolder
rm $otaFolder/tmpfolder.zip
rm $otaFile

echo ""
echo "OTA File: $otaFolder/$romFile.zip"
echo ""
echo "done."
echo ""
exit 0
