#!/usr/bin/perl -w
# This code is a part of Freek, and is released under the GPL.
# Copyright 2002 by Jorge Ferrer, jorge@jorgeferrer.com. See README
# and COPYING for more information

use Slash::DocbookXML

$object = Slash::DocbookXML->new("test-data/docbook-file.xml");
$object->validate();

$htmlFile = "/tmp/docbook-file.html";
$object->convertToHTML($htmlFile);
print("The output should be in $htmlFile");
