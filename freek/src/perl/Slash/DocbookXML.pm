# This code is a part of Freek, and is released under the GPL.
# Copyright 2002 by Alvaro del Castillo, acs@barrapunto.com. See README
# and COPYING for more information

package Slash::DocbookXML;
 
use strict;
use File::Spec;
#use Slash;
#use Slash::Utility;
#use Slash::DB::Utility;
 
use vars qw($VERSION);
#use base 'Exporter';
#use base 'Slash::DB::Utility';
#use base 'Slash::DB::MySQL';

($VERSION) = ' $Revision: 1.1 $ ' =~ /\$Revision:\s+([^\s]+)/;

sub new {
    my($class, $filePath) = @_;
    my $self = {};
    my ($volume,$dir,$fileName) = File::Spec->splitpath($filePath);
    
    bless($self, $class);
    $self->{filePath} = $filePath;
    $self->{fileName} = $fileName;
    $self->{fileDir}  = $dir;

    my $stylesheetDir = "/usr/local/freek/docbook/xsl/freek";
    $self->{htmlStylesheet} = $stylesheetDir."/html/docbook.xsl";
    $self->{multiHtmlStylesheet} = $stylesheetDir."/html/chunk.xsl";
    $self->{pdfStylesheet} = $stylesheetDir."/fo/docbook.xsl";
    return $self;
}

#FIXME
sub validate {
    my($self) = @_;
    my $valid = 1;
    print("Validating ".$self->{filePath}." <NOT IMPLEMENTED>\n");
    my $msg = "Success";
    return ($valid, $msg);
}

sub convertToHTML {
    my($self, $outputPath) = @_;
    print("Converting ".$self->{filePath}." to HTML\n");

    my ($volume,$outputDir,$fileName) = File::Spec->splitpath($outputPath);
    if (!$fileName) {
	$fileName = $self->{fileName}.".html";
	$fileName =~ s/\.xml\.html/\.html/;
	$outputPath = "$outputDir/$fileName";
    }

    &execXSLT($self->{fileName},$self->{htmlStylesheet},$outputPath);
    print("$?");

    my $msg = "Success";
    return $msg;
}

sub convertToMultiPageHTML {
    my($self, $outputPath) = @_;
    print("Converting ".$self->{filePath}." to multiple HTML pages\n");

    my $absSourceFile = File::Spec->rel2abs($self->{filePath});
    my $workDir = File::Spec->rel2abs(File::Spec->curdir());

    my ($volume,$outputDir,$fileName) = File::Spec->splitpath($outputPath);
    if (!$fileName) {
	$fileName = $self->{fileName}.".html";
	$fileName =~ s/\.xml\.html/\.html/;
	$outputPath = "$outputDir/$fileName";
    }

    chdir($outputDir);
    &execXSLT($absSourceFile, $self->{multiHtmlStylesheet});
    chdir($workDir);


    my $msg = "Success";
    return $msg;
}

#FIXME
sub convertToPDF {
    my($self, $outputFile) = @_;
    print("Converting ".$self->{filePath}." to PDF"." <NOT IMPLEMENTED>\n");

    my $msg = "Success";
    return $msg;
}

#Private Methods
sub execXSLT() {
    my ($inputFile,$styleSheet,$outputPath) = @_;
    my $saxonJAR = " /usr/local/freek/apps/saxon.jar";
    my $execStr = "java -classpath $saxonJAR com.icl.saxon.StyleSheet";
    $execStr = $execStr." -o $outputPath" if ($outputPath) ;
    $execStr = $execStr." $inputFile $styleSheet";
    print("Executing $execStr\n\n");
    system($execStr);
}

sub DESTROY {
        my($self) = @_;
}

1;
 
__END__
 
=head1 NAME

Slash::DocbookXML - Management of Docbook files
 
=head1 SYNOPSIS
 
        use Slash::DocbookXML;
 
=head1 DESCRIPTION
 
This module lets you validate Docbook XML files and convert it to
several formats by using XSL stylesheets.
 
=head1 AUTHOR
 
Jorge Ferrer, jorge@jorgeferrer.com
 
=head1 SEE ALSO
 
perl(1).
 
=cut
