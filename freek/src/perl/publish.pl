#!/usr/bin/perl -w
# This code is a part of Freek, and is released under the GPL.
# Copyright 2002 by Alvaro del Castillo, acs@barrapunto.com. See README
# and COPYING for more information

########################################################
# 
# Script de publicación de documentación del proyecto Freek
# 
# Este script depende de:
#  - Hojas de estilo XSL externas
#  - Procesador XSLT saxon
########################################################

#use strict;
use File::Spec;

#
# CONFIGURATION PARAMETERS
#
$STYLESHEET_DIR="/usr/local/freek/docbook/xsl/freek";
$SAXON_JAR = "/usr/share/java/saxon.jar";

#
# CONSTANTS
#
$HTML_STYLESHEET=$STYLESHEET_DIR."/html/docbook.xsl";
$MULTI_HTML_STYLESHEET=$STYLESHEET_DIR."/html/chunk.xsl";
#$LATEX_STYLESHEET=$STYLESHEET_DIR."/latex/docbook.xsl";
$ANNOUNCE_BOX_STYLESHEET=$STYLESHEET_DIR."/html/announce-box.xsl";
$ANNOUNCE_BOX_OUTPUT_FILE="announce-box.html";

$SAXON_PROCESSOR = "java -classpath $SAXON_JAR com.icl.saxon.StyleSheet";


#
# XSLT PROCESSORS
#

sub transformXML() {
    my ($inputFile,$styleSheet,$outputFile) = @_;
    $execStr = "$SAXON_PROCESSOR";
    $execStr = $execStr." -o $outputFile" if ($outputFile) ;
    $execStr = $execStr." $inputFile $styleSheet";
    print("Executing $execStr\n");
    system($execStr);
}

#
# METHODS
#

sub convertToSingleHTML {
    my ($targetDir, $sourceFile) = @_;
    my ($name,$ext) = split /\./, $sourceFile;

    my $outputFile = "$sourceFile.html";
    $outputFile =~ s/\.xml\.html/\.html/;
    $outputFile = "$targetDir/$outputFile";

    &transformXML($sourceFile,$HTML_STYLESHEET,$outputFile);
    print("$?");
}

sub convertToNavigableHTML {
    my ($targetDir, $sourceFile) = @_;
    my ($name,$ext) = split /\./, $sourceFile;

    $absSourceFile = File::Spec->rel2abs($sourceFile);
    $workDir = File::Spec->rel2abs(File::Spec->curdir());

    chdir($targetDir);
    &transformXML($absSourceFile, $MULTI_HTML_STYLESHEET);
    chdir($workDir);
}

sub showHelp {
    print("Syntax error.\n");
    print("\t./publish.pl target-directory source-name\n");
}

sub publish {
    my ($baseTargetDir, $sourceName) = @_;

    my $sourceFile = "$sourceName/$sourceName.xml";
    my $targetDir = "$baseTargetDir/$sourceName";
    print("Publishing $sourceFile and its files to $baseTargetDir\n");
    mkdir($targetDir,0775);
    &copyFiles($baseTargetDir, $sourceName, $sourceFile);

    &createAnnounceBox("$targetDir", $sourceFile);
    &convertToSingleHTML($baseTargetDir, $sourceFile);
    &convertToNavigableHTML($targetDir, $sourceFile);
}

sub createAnnounceBox {
    my ($targetDir, $sourceFile) = @_;
    &transformXML($sourceFile,$ANNOUNCE_BOX_STYLESHEET,
		  "$targetDir/$ANNOUNCE_BOX_OUTPUT_FILE");

}
sub copyFiles {
    my ($targetDir, $sourceDir, $sourceFile) = @_;
    system("cp -R $sourceFile $targetDir/$sourceDir/");
    system("cp -R $sourceDir/img $targetDir/$sourceDir/") if -e "$sourceDir/img";
    system("cp -R $sourceDir/extra $targetDir/$sourceDir/") if -e "$sourceDir/extra";
}

#
# MAIN
#
sub main () {
    my ($baseTargetDir, @sourceNames) = @_;
    if (!baseTargetDir) { 
	showHelp();
    } else {
	foreach $sourceName (@sourceNames) {
	    &publish($baseTargetDir, $sourceName);
	}
    }
}

&main(@ARGV);
