#!/usr/bin/perl -w
# This code is a part of Freek, and is released under the GPL.
# Copyright 2002 by Alvaro del Castillo, acs@barrapunto.com. See README
# and COPYING for more information
 
use strict;
use Slash;
use Slash::Display;
use Slash::Utility;
 
sub main {
        my $slashdb   = getCurrentDB();
        my $constants = getCurrentStatic();
        my $user      = getCurrentUser();
        my $form      = getCurrentForm();
 
        header("Upload a file to Freek", "");
        print "Subiendo el fichero ...";
        my $upload = $form->{query_apache}->upload;
        print "<br>No me has enviado el fichero, pecador" if !$upload;
        print "<br>Upload: $upload";
 
        my $filename = $upload->filename;
        print "<br>Nombre del fichero: $filename<br>";
        my $file = $upload->fh;
        my $size = $upload->size;
 
        print "Tama<F1>o del fichero: $size<br>";
 
        print "No tengo acceso al fichero<br>" if !$file;
 
        open(FILE, "/tmp/$filename");
        my $buffer;
        while (read $file, $buffer, 1024) {
                print $buffer;
                print FILE $buffer;
        }
        close FILE;
}
 
main();
