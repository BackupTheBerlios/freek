# This code is a part of Freek, and is released under the GPL.
# Copyright 2002 by Jorge Ferrer, jorge@jorgeferrer.com. See README
# and COPYING for more information

package Slash::Publisher;

use strict;
#use Slash;
#use Slash::Utility;
#use Slash::DB::Utility;

use vars qw($VERSION);
#use base 'Exporter';
#use base 'Slash::DB::Utility';
#use base 'Slash::DB::MySQL';

($VERSION) = ' $Revision: 1.1 $ ' =~ /\$Revision:\s+([^\s]+)/;

sub new {
    my($class) = @_;
    my $self = {};
    
    bless($self, $class);
    return $self;
}

sub publishDocbookDocument {
    my ($sourceDir, $docbookFile, $docId, $targetDir) = @_;

    my $sourceFile = "$sourceDir/$docbookFile";
    $targetDir = "$targetDir/$docId";

    print("Publishing $sourceFile and its files to $targetDir\n");
    mkdir($targetDir,0775);
    &copyFiles($baseTargetDir, $sourceName, $sourceFile);
    my $docbook = Slash::DocbookXML->new($sourceFile);
    $docbook->convertToHTML("$targetDir/$docId.xml");
}

#private
sub copyFiles {
    my ($targetDir, $sourceDir, $sourceFile) = @_;
    system("cp -R $sourceFile $targetDir/$sourceDir/");
    system("cp -R $sourceDir/img $targetDir/$sourceDir/") if -e "$sourceDir/img";
    system("cp -R $sourceDir/extra $targetDir/$sourceDir/") if -e "$sourceDir/extra";
}


sub DESTROY {
        my($self) = @_;
}

1;
 
__END__
 
=head1 NAME

Slash::Publisher - Publishes documents in the Slash framework
 
=head1 SYNOPSIS
 
        use Slash::Publisher;
 
=head1 DESCRIPTION
 
This module lets you publish documents in Docbook format (future
versions may support other formats) in the Slash framework
 
=head1 AUTHOR
 
Jorge Ferrer, jorge@jorgeferrer.com
 
=head1 SEE ALSO
 
perl(1).
 
=cut
